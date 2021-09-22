//
//  HomeDataSource.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 11.08.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI
import BakingRecipeStrings

import BakingRecipeFoundation
import BackAppCore
import GRDB

import Combine

class HomeDataSource: UITableViewDiffableDataSource<HomeSection, RecipeItem> {
    
    private var tokens = Set<AnyCancellable>()

    private var appData: BackAppData
    
    init(appData: BackAppData, tableView: UITableView) {
        self.appData = appData
        
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
                self.update(animated: true)
            }
            .store(in: &tokens)
    }
    
    ///refetches the data and renders the sections and items
    func update(animated: Bool = true, searchText: String? = nil) {
        DispatchQueue.global(qos: .background).async {
            var searchText = searchText
            if searchText?.isEmpty ?? true {
                searchText = nil
            }
            var snapshot = NSDiffableDataSourceSnapshot<HomeSection, RecipeItem>()
            let appData = self.appData

            if !appData.favorites.isEmpty && searchText == nil {

                //favorites
                let favoriteItems = appData.favorites.map { $0.item(appData: appData) }
                snapshot.appendSections([.favourites])
                snapshot.appendItems(favoriteItems, toSection: .favourites)
            }

            //normal
            let recipeItems: [RecipeItem]
            if let searchText = searchText {
                let filteredRecipes = appData.allRecipes.filter { $0.formattedName.localizedCaseInsensitiveContains(searchText) }
                recipeItems = filteredRecipes.map { $0.item(appData: appData) }
            } else {
            recipeItems = appData.allRecipes.map { $0.item(appData: appData) }
            }
            snapshot.appendSections([.recipes])
            snapshot.appendItems(recipeItems, toSection: .recipes)

            //update
            DispatchQueue.main.async { //force the main thread since UITableView should be updated from the main thread
                self.apply(snapshot, animatingDifferences: animated)
            }
        }
    }

    private func fetchRecipeId(from indexPath: IndexPath) -> Int64? {
        guard let item = self.itemIdentifier(for: indexPath) else {
            print("error finding item at IndexPath \(indexPath)")
            return nil
        }
        return Int64(item.id)
    }

    /// tell the appData to delete the recipe wtih a specified id
    public func deleteRecipe(at indexPath: IndexPath) {
        DispatchQueue.global(qos: .userInteractive).async { // different thread to not interrupt the ui

            // get the id of the item which corresponds a recipe
            guard let id = self.fetchRecipeId(from: indexPath) else { return }

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
            NotificationCenter.default.post(name: .homeShouldPopSplitVC, object: nil)
            NotificationCenter.default.post(name: .recipesChanged, object: nil)
            NotificationCenter.default.post(name: .homeNavBarShouldReload, object: nil)
        }
    }

    public func favorite(at indexPath: IndexPath) -> Bool {
        guard let id = fetchRecipeId(from: indexPath) else { return false}
        return (appData.record(with: id, of: Recipe.self)?.isFavorite) ?? false
    }

    ///tell the appData to favourite a recipe with a specified id
    public func setFavorite(_ favorite: Bool, at indexPath: IndexPath) {
        DispatchQueue.global(qos: .userInteractive).async { //different thread to not interrupt the ui
            /// get the id of the item which corresponds a recipe
            guard let id = self.fetchRecipeId(from: indexPath) else { return }

            //get the recipe and ensure it exists
            guard var recipe = self.appData.record(with: id, of: Recipe.self) else {
                print("Error fetching recipe with id \(id)")
                return
            }

            recipe.isFavorite = favorite

            self.appData.update(recipe) { _ in

                //update
                NotificationCenter.default.post(name: .recipesChanged, object: nil)
                NotificationCenter.default.post(name: .homeShouldPopSplitVC, object: nil)
            }
        }
    }

    public func addRecipe() -> Recipe {
        // first create a new number by incrementing the last one since the recipes are sorted by their number
        let newNumber = (appData.allRecipes.last?.number ?? -1) + 1

        // create a fresh recipe this needs to be a var because the id is going to change after insert
        var recipe = Recipe.init(number: newNumber)

        //insert
        appData.insert(&recipe)

        return recipe
    }

    public func exportAllRecipesToFile() -> URL {
        appData.exportAllRecipesToFile()
    }

    public func share(_ recipe: Recipe) -> URL {
        appData.exportRecipesToFile(recipes: [recipe])
    }

    func recipeBinding(with id: Int64) -> Binding<Recipe> {
        Binding { self.appData.record(with: id)! } set: { self.appData.update($0)}
    }


    func recipe(from indexPath: IndexPath) -> Recipe? {
        guard let id = fetchRecipeId(from: indexPath) else { return nil }
        return appData.record(with: id)
    }

    func open(urls: [URL]) {
        DispatchQueue.global(qos: .background).async {
            //load recipes
            for url in urls {
                self.appData.open(url)
            }

            self.update(animated: true)
        }
    }

    
    /// enable deleting recipes
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        // make sure the editing style is delete
        guard editingStyle == .delete else {
            return
        }
        
        // delete the recipe
        self.deleteRecipe(at: indexPath)
    }

    //wether a row can be deleted or not
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        itemIdentifier(for: indexPath) != nil
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
    
    /// moving recipes
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let snapshot = snapshot()
        guard destinationIndexPath.row < snapshot.numberOfItems(inSection: .recipes) else { reset(); return }
        guard destinationIndexPath.section == 0 && snapshot.numberOfSections == 1 || destinationIndexPath.section == 1 && snapshot.numberOfSections == 2 else { reset(); return}
        guard snapshot.numberOfItems(inSection: .recipes) > sourceIndexPath.row else { reset(); return }
        appData.moveRecipe(from: sourceIndexPath.row, to: destinationIndexPath.row)
    }

    //wether a row can be moved or not
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if appData.favorites.isEmpty {
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

//MARK: UISearchResults
extension HomeDataSource: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.searchTextField.text {
            self.update(animated: false, searchText: searchText)
        } else {
            self.update(animated: false)
        }
    }
}
