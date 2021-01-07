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

public extension Notification.Name {
    static var homeNavBarShouldReload = Self.init(rawValue: "homeNavBarShouldReload")
}

class HomeDataSource: UITableViewDiffableDataSource<HomeSection,RecipeItem> {
    // storage object for recipes
    var appData: BackAppData
    
    init(appData: BackAppData, tableView: UITableView) {
        self.appData = appData
        
        super.init(tableView: tableView) { (_, indexPath, recipeItem) -> UITableViewCell? in
                //recipeCell
                let recipeCell = RecipeCell(name: recipeItem.text, minuteLabel: recipeItem.minuteLabel, imageData: recipeItem.imageData, reuseIdentifier: Strings.recipeCell)
                return recipeCell
        }
    }
    
    /// updates and rerenders the tableview
    func update(animated: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<HomeSection, RecipeItem>()
        
        //append sections and items
        if appData.favoriteItems.isEmpty {
            snapshot.appendSections([HomeSection.recipes])
            snapshot.appendItems(appData.allRecipesItems, toSection: .recipes)
        } else {
            snapshot.appendSections(HomeSection.allCases)
            snapshot.appendItems(appData.allRecipesItems, toSection: .recipes)
            snapshot.appendItems(appData.favoriteItems, toSection: .favourites)
        }
        

        self.apply(snapshot, animatingDifferences: animated)
    }
    
    func reloadRecipes() {
        var snapshot = self.snapshot()
        snapshot.reloadSections([.recipes])
        self.apply(snapshot)
    }
    
    /// resetting tableview used for reordering
    private func reset() {
        var snapshot = self.snapshot()
        snapshot.deleteAllItems()
        self.apply(snapshot, animatingDifferences: false)
        self.update(animated: false)
    }
    
    
    /// deleting recipes
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        // make sure editingStyle is delete
        guard editingStyle == .delete else {
            return
        }
        
        ///make sure the item exists and there is an recipe that belongs to this item
        guard let item = itemIdentifier(for: indexPath), var recipe = self.appData.object(with: item.id, of: Recipe.self) else {
            return
        }
        
        func deleteRecipe() {
            //delete the item and apply changes
            snapshot.deleteItems([item])
            apply(snapshot, animatingDifferences: true) {
                _ = self.appData.delete(recipe)
                NotificationCenter.default.post(name: .homeNavBarShouldReload, object: nil)
            }
        }
        
        var snapshot = self.snapshot()
        
        if appData.favoriteItems.isEmpty {
            deleteRecipe()
        } else {
            if indexPath.section == HomeSection.recipes.rawValue {
                
                deleteRecipe()
            } else if indexPath.section == HomeSection.favourites.rawValue {
                
                //delete the item from the list and make it a non favourite
                snapshot.deleteItems([item])
                recipe.isFavorite = false
                apply(snapshot, animatingDifferences: true) {
                    _ = self.appData.update(recipe)
                }
            }
        }
    }
    
        // moving recipes
        override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
            guard destinationIndexPath.row < appData.allRecipes.count else { reset(); return }
            guard destinationIndexPath.section == 0 else { reset(); return}
            guard appData.allRecipes.count > sourceIndexPath.row else { reset(); return }
            DispatchQueue.global(qos: .userInteractive).async {
                self.appData.moveRecipe(from: sourceIndexPath.row, to: destinationIndexPath.row)
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
        if appData.favoriteItems.isEmpty {
            return true
        } else {
            return indexPath.section == HomeSection.recipes.rawValue
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let section = HomeSection.init(rawValue: section) else { return nil }
        
        return section.headerTitle(favouritesEmpty: appData.favoriteItems.isEmpty)
    }
    
}
