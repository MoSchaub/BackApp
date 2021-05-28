//
//  HomeDataSource.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 11.08.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import UIKit
import BackAppCore
import BakingRecipeStrings
import BakingRecipeCells
import BakingRecipeFoundation
import Combine

public func fetchDataCompletionHandler(completion: Subscribers.Completion<Error>) {
    switch completion {
    case .finished:
        _ = ""
    case .failure(let error):
        print("error fetching data", error)
    }
}


class HomeDataSource: UITableViewDiffableDataSource<HomeSection, RecipeItem> {
    
    class ViewModel {
        
        ///storage object to access the data
        private var appData: BackAppData
        
        ///subscribers
        public var tokens = Set<AnyCancellable>()
        
        ///get items for recipes
        func getRecipesItems(favouritesOnly: Bool = false) -> [RecipeItem] {
            appData.getRecipesItems(favouritesOnly: favouritesOnly)
        }
        
        /// moving recipes from source to destination
        func moveRecipe(from source: Int, to destination: Int) {
            appData.moveRecipe(from: source, to: destination)
        }
        
        init(appData: BackAppData) {
            self.appData = appData
        }
        
        deinit {
            // stop listening to subscribers
            _ = tokens.map { $0.cancel() }
        }
        
        /// tell the appData to delete the recipe wtih a specified id
        func deleteRecipe(with id: Int) {
            /// `databaseAutoUpdatesDisabled` is to ensure that not 2 operations are performed simultaneously
            ///  which could crash the app since the database can only be accessed from one thread at a time
            if !databaseAutoUpdatesDisabled {
                databaseAutoUpdatesDisabled = true
                
                //ensure the recipe exits and get the recipe with the specified id
                guard let recipe = self.appData.object(with: id, of: Recipe.self) else {
                    print("Error fetching recipe with id \(id)")
                    return
                }
                
                //tell the appData to delete the recipe
                guard self.appData.delete(recipe) else {
                    print("Error deleting recipe with id \(id)")
                    return
                }
                
                databaseAutoUpdatesDisabled = false
                
                ///reload the navbar since deleting the recipe could result in `appData.allRecipes` being empty
                ///the navbar would not automatically update since `databaseAutoUpdatesDisabled` is true and
                ///this could lead to ui bugs in the navbar e. g. an not disabled editButton
                NotificationCenter.default.post(name: .homeNavBarShouldReload, object: nil)
            }
        }
        
        ///tell the appData to favourite a recipe with a specified id
        /// - Note: mainly used for `isFavourite = false`
        func toggleFavoriteRecipe(with id: Int) {
            
            /// `databaseAutoUpdatesDisabled` is to ensure that not 2 operations are performed simultaneously
            ///  which could crash the app since the database can only be accessed from one thread at a time
            if !databaseAutoUpdatesDisabled {
                databaseAutoUpdatesDisabled = true
                
                //get the recipe and ensure it exists
                guard var recipe = self.appData.object(with: id, of: Recipe.self) else {
                    print("Error fetching recipe with id \(id)")
                    return
                }
                
                recipe.isFavorite.toggle()
                
                guard self.appData.update(recipe) else {
                    print("Error updating recipe with id \(id)")
                    return
                }
                
                databaseAutoUpdatesDisabled = false
            }
        }
    }
    
    /// view model for homeView
    private var viewModel: HomeDataSource.ViewModel
    
    init(appData: BackAppData, tableView: UITableView) {
        self.viewModel = ViewModel(appData: appData)
        
        super.init(tableView: tableView) { (_, _, recipeItem) -> UITableViewCell? in
            return RecipeCell(name: recipeItem.text, minuteLabel: recipeItem.minuteLabel, imageData: recipeItem.imageData, reuseIdentifier: Strings.recipeCell)
        }
        
        // set animation
        self.defaultRowAnimation = .fade
        
        // add publisher to update when the database changes
        NotificationCenter.default.publisher(for: Notification.Name.recipesChanged)
            .sink { _ in
                self.update(animated: true)
            }
            .store(in: &viewModel.tokens)
    }
    
    ///refetches the data and renders the sections and items
    func update(animated: Bool = true) {
        
        var snapshot = NSDiffableDataSourceSnapshot<HomeSection, RecipeItem>()
        
        //append sections and items
        if !viewModel.getRecipesItems(favouritesOnly: true).isEmpty {
            // case 1 favorites and all recipes
            snapshot.appendSections(HomeSection.allCases)
            snapshot.appendItems(viewModel.getRecipesItems(favouritesOnly: true), toSection: .favourites)
            snapshot.appendItems(viewModel.getRecipesItems(), toSection: .recipes)
        } else {
            //case 2 only all recipes
            snapshot.appendSections([HomeSection.recipes])
            snapshot.appendItems(viewModel.getRecipesItems(), toSection: .recipes)
        }
        
        //force the main thread since UITableView should be updated from the main thread
        DispatchQueue.main.async {
            // apply the changes
            self.apply(snapshot, animatingDifferences: animated)
        }
    }
    
    /// resetting tableview used for reordering
    private func reset() {
        var snapshot = self.snapshot()
        snapshot.deleteAllItems()
        self.apply(snapshot, animatingDifferences: false)
        self.update(animated: false)
    }
    
    /// enable deleting recipes
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        //make sure the editing style is delete
        guard editingStyle == .delete else {
            return
        }
        
        //get the item
        guard let item = self.itemIdentifier(for: indexPath) else {
            return
        }
        
        if tableView.numberOfSections == 2, indexPath.section == 0 {
            
            //toggle favourite
            DispatchQueue.global(qos: .userInteractive).async { // different thread to not interrupt the ui
                self.viewModel.toggleFavoriteRecipe(with: item.id)
            }
        } else {
            
            //delete the recipe
            DispatchQueue.global(qos: .userInteractive).async { // different thread to not interrupt the ui
                self.viewModel.deleteRecipe(with: item.id)
            }
        }
    }
    
    /// moving recipes
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard destinationIndexPath.row < viewModel.getRecipesItems().count else { reset(); return }
        guard destinationIndexPath.section == 0 && snapshot().numberOfSections == 1 || destinationIndexPath.section == 1 && snapshot().numberOfSections == 2 else { reset(); return}
        guard viewModel.getRecipesItems().count > sourceIndexPath.row else { reset(); return }
        DispatchQueue.global(qos: .userInteractive).async {
            self.viewModel.moveRecipe(from: sourceIndexPath.row, to: destinationIndexPath.row)
            DispatchQueue.main.async {
                self.update(animated: false)
            }
        }
        
    }
    
    //wether a row can be deleted or not
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if itemIdentifier(for: indexPath) != nil {
            return true
        } else {return false}
    }
    
    //wether a row can be moved or not
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if viewModel.getRecipesItems(favouritesOnly: true).isEmpty {
            return true
        } else {
            return indexPath.section == HomeSection.recipes.rawValue
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let section = HomeSection.init(rawValue: section) else { return nil }
        
        return section.headerTitle(favouritesEmpty: snapshot().numberOfSections != 2)
    }
    
}
