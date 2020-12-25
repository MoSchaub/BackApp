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

extension UITableViewCell {
    func setupPlainCell(text: String) {
        let color = UIColor.backgroundColor
        let image = UIImage(systemName: "chevron.up")
        image?.applyingSymbolConfiguration(.init(textStyle: .body, scale: .large))
        
        textLabel?.text = text
        backgroundColor = color
        accessoryView = UIImageView(image: image)
        accessoryView?.tintColor = .cellTextColor
        selectionStyle = .none
    }
}

class HomeDataSource: UITableViewDiffableDataSource<HomeSection,TextItem> {
    // storage object for recipes
    var appData: BackAppData

    init(appData: BackAppData, tableView: UITableView) {
        self.appData = appData
        
        super.init(tableView: tableView) { (_, indexPath, homeItem) -> UITableViewCell? in
            // Configuring cells
            if let recipeItem = homeItem as? RecipeItem{
                //recipeCell
                let recipeCell = RecipeCell(name: recipeItem.text, minuteLabel: recipeItem.minuteLabel, imageData: recipeItem.imageData, reuseIdentifier: Strings.recipeCell)
                return recipeCell
            } else if let detailItem = homeItem as? DetailItem, let cell = tableView.dequeueReusableCell(withIdentifier: Strings.detailCell, for: indexPath) as? DetailCell {
                // Detail Cell (RoomTemp und About)
                cell.textLabel?.text = detailItem.text
                cell.detailTextLabel?.text = detailItem.detailLabel
                return cell
            } else {
                // plain cell
                let cell = tableView.dequeueReusableCell(withIdentifier: Strings.plainCell, for: indexPath) //plain cells
                cell.setupPlainCell(text: homeItem.text)
                return cell
            }
        }
    }
    
    /// updates and rerenders the tableview
    func update(animated: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<HomeSection, TextItem>()
        snapshot.appendSections(HomeSection.allCases)
        snapshot.appendItems(appData.allRecipesItems, toSection: .recipes)
        snapshot.appendItems(appData.settingsItems, toSection: .settings)
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
        if editingStyle == .delete, indexPath.section == 0, let item = itemIdentifier(for: indexPath), let recipe = self.appData.recipe(with: item.id) {
            var snapshot = self.snapshot()
            snapshot.deleteItems([item])
            apply(snapshot, animatingDifferences: true) {
                _ = self.appData.delete(recipe)
            }
        }
    }
    
//    func deleteRecipe(_ id: Int) -> Bool {
//        if let index = recipeStore.allRecipes.firstIndex(where: { $0.id == id }) {
//            return self.recipeStore.deleteRecipe(at: index)
//        } else { return false }
//    }
    
//    // moving recipes
//    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
//        guard destinationIndexPath.row < appData.allRecipes.count else { reset(); return }
//        guard destinationIndexPath.section == 0 else { reset(); return}
//        guard appData.allRecipes.count > sourceIndexPath.row else { reset(); return }
//        DispatchQueue.global(qos: .userInteractive).async {
//            self.recipeStore.moveRecipe(from: sourceIndexPath.row, to: destinationIndexPath.row)
//            DispatchQueue.main.async {
//                self.update(animated: false)
//            }
//        }
//
//    }
    
    //wether a row can be deleted or not
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if itemIdentifier(for: indexPath) as? RecipeItem != nil {
            return true
        } else {return false}
    }
    
    //wether a row can be moved or not
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
//        if indexPath.section == 0 {
//            return true
//        } else {return false}
        return false
    }

}
