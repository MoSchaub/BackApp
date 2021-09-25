//
//  RecipeListDataSource.swift
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

class RecipeListDataSource: UITableViewDiffableDataSource<HomeSection, BackAppData.RecipeListItem> {

    private var searchText: String? {
        didSet {
            attachRecipeListPublisher()
        }
    }

    private var numberOfFavorites: Int!

    private var recipesListPublisher: AnyCancellable!

    init(tableView: UITableView) {

        super.init(tableView: tableView) { (_, _, recipeListItem) -> UITableViewCell? in
            RecipeCell(name: recipeListItem.recipe.formattedName, minuteLabel: "\(recipeListItem.stepCount) \(Strings.steps)", imageData: recipeListItem.recipe.imageData, reuseIdentifier: Strings.recipeCell)
        }
        self.setup()
    }
    
    deinit {
        // stop listening to subscribers
        recipesListPublisher.cancel()
    }
    
    private func setup() {
        // set animation
        self.defaultRowAnimation = .fade
        attachRecipeListPublisher()
        // add publisher to update when the database changes
    }

    private func attachRecipeListPublisher() {
        self.recipesListPublisher = BackAppData.shared.recipeListPublisher
            .sink(receiveCompletion: { _ in }) { recipeListItems in
                self.update(recipeListItems: recipeListItems)
            }
    }
    
    ///refetches the data and renders the sections and items
    private func update(recipeListItems: [BackAppData.RecipeListItem]) {
        var snapshot = NSDiffableDataSourceSnapshot<HomeSection, BackAppData.RecipeListItem>()

        var recipeListItems = recipeListItems
        let favoriteItems = recipeListItems.filter{ $0.recipe.isFavorite }
        if !favoriteItems.isEmpty && self.searchText == nil {
            numberOfFavorites = favoriteItems.count
            //favorites
            snapshot.appendSections([.favourites])
            snapshot.appendItems(favoriteItems, toSection: .favourites)
        } else {
            numberOfFavorites = 0
        }

        //normal
        if let searchText = self.searchText {
            recipeListItems = recipeListItems.filter { $0.recipe.formattedName.localizedCaseInsensitiveContains(searchText)}
        } else {
            recipeListItems = recipeListItems.filter { !$0.recipe.isFavorite }
        }
        snapshot.appendSections([.recipes])
        snapshot.appendItems(recipeListItems, toSection: .recipes)

        //update
        DispatchQueue.main.async { //force the main thread since UITableView should be updated from the main thread
            self.apply(snapshot, animatingDifferences: false)
        }
    }

    /// enable deleting recipes
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // get the recipe
        guard let recipe = self.itemIdentifier(for: indexPath)?.recipe else { return }
        //delete it
        BackAppData.shared.delete(recipe)
    }

    //wether a row can be deleted or not
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        itemIdentifier(for: indexPath) != nil
    }

    /// resetting tableview used for reordering
    private func reset() {
        attachRecipeListPublisher()
    }
    
    /// moving recipes
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let snapshot = snapshot()
        guard destinationIndexPath.row < snapshot.numberOfItems(inSection: .recipes) else { reset(); return }
        guard destinationIndexPath.section == 0 && snapshot.numberOfSections == 1 || destinationIndexPath.section == 1 && snapshot.numberOfSections == 2 else { reset(); return}
        guard snapshot.numberOfItems(inSection: .recipes) > sourceIndexPath.row else { reset(); return }
        BackAppData.shared.moveRecipe(from: sourceIndexPath.row, to: destinationIndexPath.row)
    }

    //wether a row can be moved or not
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if self.numberOfFavorites == 0 {
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
extension RecipeListDataSource: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.searchTextField.text {
//            self.update(animated: false, searchText: searchText)
            if !searchText.isEmpty {
                self.searchText = searchText
            } else {
                self.searchText = nil
            }
        }
    }
}
