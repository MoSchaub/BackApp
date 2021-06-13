//
//  HomeDataSource.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 11.08.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import UIKit
import BakingRecipeStrings

import BakingRecipeFoundation
import BackAppCore
import GRDB

import Combine

class HomeDataViewModel {
    
    ///storage object to access the data
    private var appData: BackAppData
    
    init(appData: BackAppData) {
        self.appData = appData
    }
    
    /// fetch recipeItems
    private func getRecipeItems(favoritesCompletion: @escaping ([RecipeItem]) -> Void, normalCompletion: @escaping ([RecipeItem]) -> Void, updateCompletion: @escaping () -> Void) {
        if !appData.favorites.isEmpty {
            favoritesCompletion(appData.favorites.map { $0.item(steps: appData.steps(with: $0.id!))})
        }
        normalCompletion(appData.allRecipes.map { $0.item(steps: appData.steps(with: $0.id!))})
        updateCompletion()
    }
    
    ///moving recipes from source to destination
    private func moveRecipe(from source: Int, to destination: Int) {
        appData.moveRecipe(from: source, to: destination)
    }
    
    /// tell the appData to delete the recipe wtih a specified id
    private func deleteRecipe(with id: Int64) {
            
            //ensure the recipe exits and get the recipe with the specified id
            guard let recipe = self.appData.record(with: id, of: Recipe.self) else {
                print("Error fetching recipe with id \(id)")
                return
            }
            
            //tell the appData to delete the recipe
            guard self.appData.delete(recipe) else {
                print("Error deleting recipe with id \(id)")
                return
            }
        
        //update
        NotificationCenter.default.post(name: .recipesChanged, object: nil)
        NotificationCenter.default.post(name: .homeNavBarShouldReload, object: nil)
    }
    
    ///tell the appData to favourite a recipe with a specified id
    /// - Note: mainly used for `isFavourite = false`
    private func toggleFavoriteRecipe(with id: Int64) {
        
        //get the recipe and ensure it exists
        guard var recipe = self.appData.record(with: id, of: Recipe.self) else {
            print("Error fetching recipe with id \(id)")
            return
        }
        
        recipe.isFavorite.toggle()
        
        appData.update(recipe) { _ in
            
            //update
            NotificationCenter.default.post(name: .recipesChanged, object: nil)
        }
    }
    
    func updateSnapshot(completion: @escaping (NSDiffableDataSourceSnapshot<HomeSection, RecipeItem>) -> Void)  {
        DispatchQueue.global(qos: .background).async {
            var snapshot = NSDiffableDataSourceSnapshot<HomeSection, RecipeItem>()
            
            self.getRecipeItems(favoritesCompletion: { favoriteItems in
                snapshot.appendSections([.favourites])
                snapshot.appendItems(favoriteItems, toSection: .favourites)
            }, normalCompletion: { recipeItems in
                snapshot.appendSections([.recipes])
                snapshot.appendItems(recipeItems, toSection: .recipes)
            }, updateCompletion: {
                completion(snapshot)
            })
        }
    }
    
    
    func commitEditingStyle(editingStyle: UITableViewCell.EditingStyle, indexPath: IndexPath, numberOfSections: Int, item: RecipeItem?) {
        
        //make sure the editing style is delete
        guard editingStyle == .delete else {
            return
        }
        
        //get the item
        guard let item = item else {
            return
        }
        
        if numberOfSections == 2, indexPath.section == 0 {
            
            //toggle favourite
            DispatchQueue.global(qos: .userInteractive).async { // different thread to not interrupt the ui
                self.toggleFavoriteRecipe(with: Int64(item.id))
            }
        } else {
            
            //delete the recipe
            DispatchQueue.global(qos: .userInteractive).async { // different thread to not interrupt the ui
                self.deleteRecipe(with: Int64(item.id))
            }
        }
    }
    
    func move(from sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath, snapshot: NSDiffableDataSourceSnapshot<HomeSection, RecipeItem>, reset: @escaping () -> Void) {
        guard destinationIndexPath.row < snapshot.numberOfItems(inSection: .recipes) else { reset(); return }
        guard destinationIndexPath.section == 0 && snapshot.numberOfSections == 1 || destinationIndexPath.section == 1 && snapshot.numberOfSections == 2 else { reset(); return}
        guard snapshot.numberOfItems(inSection: .recipes) > sourceIndexPath.row else { reset(); return }
        self.moveRecipe(from: sourceIndexPath.row, to: destinationIndexPath.row)
    }
    
    func canEditRow(item: RecipeItem?) -> Bool {
        if item != nil {
            return true
        } else {return false}
    }
    
    func canMoveRow(at indexPath: IndexPath) -> Bool {
        return indexPath.section == HomeSection.recipes.rawValue
    }
    
    func headerTitle(section: Int, numberOfSections: Int) -> String? {
        guard let section = HomeSection.init(rawValue: section) else { return nil }
        
        return section.headerTitle(favouritesEmpty: numberOfSections != 2)
    }
    
}

class HomeDataSource: UITableViewDiffableDataSource<HomeSection, RecipeItem> {
    
    /// view model for homeView
    private var viewModel: HomeDataViewModel
    
    private var tokens = Set<AnyCancellable>()
    
    init(appData: BackAppData, tableView: UITableView) {
        self.viewModel = HomeDataViewModel(appData: appData)
        
        super.init(tableView: tableView) { (_, _, recipeItem) -> UITableViewCell? in
            return RecipeCell(name: recipeItem.text, minuteLabel: recipeItem.minuteLabel, imageData: recipeItem.imageData, reuseIdentifier: Strings.recipeCell)
        }
        self.setup()
    }
    
    deinit {
        // stop listening to subscribers
        _ = tokens.map { $0.cancel() }
    }
    
    private func setup() {
        // set animation
        self.defaultRowAnimation = .fade
        
        // add publisher to update when the database changes
        NotificationCenter.default.publisher(for: Notification.Name.recipesChanged)
            .sink { _ in
                self.update(animated: false)
            }
            .store(in: &tokens)
    }
    
    ///refetches the data and renders the sections and items
    func update(animated: Bool = true) {
        self.viewModel.updateSnapshot { snapshot in
            DispatchQueue.main.async { //force the main thread since UITableView should be updated from the main thread
                self.apply(snapshot, animatingDifferences: animated)
            }
        }
    }
    
    /// resetting tableview used for reordering
    private func reset() {
        var snapshot = self.snapshot()
        snapshot.deleteAllItems()
        
        DispatchQueue.main.async {
            self.apply(snapshot, animatingDifferences: false)
            self.update(animated: false)
        }
    }
    
    /// enable deleting recipes
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        viewModel.commitEditingStyle(editingStyle: editingStyle, indexPath: indexPath, numberOfSections: tableView.numberOfSections, item: self.itemIdentifier(for: indexPath))
        if let item = self.itemIdentifier(for: indexPath) {
            var snapshot = self.snapshot()
            snapshot.deleteItems([item])
            self.apply(snapshot, animatingDifferences: false)
        }
    }
    
    /// moving recipes
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        viewModel.move(from: sourceIndexPath, to: destinationIndexPath, snapshot: snapshot(), reset: {self.reset()})
    }
    
    //wether a row can be deleted or not
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        viewModel.canEditRow(item: itemIdentifier(for: indexPath))
    }
    
    //wether a row can be moved or not
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        viewModel.canMoveRow(at: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        viewModel.headerTitle(section: section, numberOfSections: snapshot().numberOfSections)
    }
    
}
