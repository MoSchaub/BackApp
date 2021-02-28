//
//  HomeDataSource.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 11.08.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import UIKit
import BackAppCore
import BackAppExtra
import BakingRecipeStrings
import BakingRecipeSections
import BakingRecipeItems
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



public extension Notification.Name {
    static var homeNavBarShouldReload = Self.init(rawValue: "homeNavBarShouldReload")
}

class HomeDataSource: UITableViewDiffableDataSource<HomeSection, RecipeItem> {
    
    class ViewModel {
        
        ///storage object to access the data
        private var appData: BackAppData
        
        ///subscribers
        public var tokens = Set<AnyCancellable>()
        
        ///get items for recipes
        func getRecipesItems(favouritesOnly: Bool = false) -> [RecipeItem] {
            var items = [RecipeItem]() //helper var to return the values
            
            appData.getRecipes(favouritesOnly: favouritesOnly)
                .sink(receiveCompletion: fetchDataCompletionHandler(completion:)) { [self] recipes in
                    items = recipes.map { appData.recipeItem(for: $0) }
                }.store(in: &tokens)
            
            return items
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
    }
    
    /// view model for homeView
    private var viewModel: HomeDataSource.ViewModel
    
    init(appData: BackAppData, tableView: UITableView) {
        self.viewModel = ViewModel(appData: appData)
        
        super.init(tableView: tableView) { (_, _, recipeItem) -> UITableViewCell? in
            return RecipeCell(name: recipeItem.text, minuteLabel: recipeItem.minuteLabel, imageData: recipeItem.imageData, id: recipeItem.id, reuseIdentifier: Strings.recipeCell)
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
        
        // apply the changes
        self.apply(snapshot, animatingDifferences: animated)
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
        
        //make sure a cell exists at that index path
        guard let cell = tableView.cellForRow(at: indexPath) as? RecipeCell else {
            return
        }
        
        //helper func
        func publisherOutputReaction(error: SqlableError?) {
            if let error = error {
                
                //something went wrong
                print(error)
            } else {
                
                //everything worked fine update the view now
                self.update(animated: true)
                NotificationCenter.default.post(name: .homeNavBarShouldReload, object: nil)
            }
        }
        
        if tableView.numberOfSections == 2, indexPath.section == 0 {
            //toggle favourite
            cell.toggleFavouriteRecipePublisher()
                .sink(receiveValue: publisherOutputReaction(error:))
                .store(in: &viewModel.tokens)
        } else {
            //delete the recipe in the cell
            cell.deleteRecipePublisher()
                .sink(receiveValue: publisherOutputReaction(error:))
                .store(in: &viewModel.tokens)
        }
    }
    
    // moving recipes
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
