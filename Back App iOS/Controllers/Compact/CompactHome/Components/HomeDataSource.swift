//
//  HomeDataSource.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 11.08.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import UIKit

class HomeDataSource: UITableViewDiffableDataSource<HomeSection,TextItem> {
    // storage object for recipes
    var recipeStore: RecipeStore

    init(recipeStore: RecipeStore, tableView: UITableView) {
        self.recipeStore = recipeStore
        
        super.init(tableView: tableView) { (_, indexPath, homeItem) -> UITableViewCell? in
            // Configuring cells
            if let recipeItem = homeItem as? RecipeItem, let recipeCell = tableView.dequeueReusableCell(withIdentifier: "recipe", for: indexPath) as? RecipeTableViewCell { //recipeCell
                recipeCell.setUp(cellData: .init(name: recipeItem.text, minuteLabel: recipeItem.minuteLabel, imageData: recipeItem.imageData))
                recipeCell.accessoryType = .disclosureIndicator
                
                return recipeCell
            } else if let detailItem = homeItem as? DetailItem { // Detail Cell (RoomTemp und About)
                let cell = tableView.dequeueReusableCell(withIdentifier: "detail", for: indexPath)
                cell.textLabel?.text = detailItem.text
                cell.detailTextLabel?.text = detailItem.detailLabel
                cell.accessoryType = .disclosureIndicator

                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "plain", for: indexPath) //plain cells
                cell.textLabel?.text = homeItem.text
                cell.accessoryView = UIImageView(image: UIImage(systemName: "chevron.up"))
                cell.accessoryView?.tintColor = .tertiaryLabel
                
                return cell
            }
        }
        //update(animated: false)
    }
    
    /// updates and rerenders the tableview
    func update(animated: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<HomeSection, TextItem>()
        snapshot.appendSections(HomeSection.allCases)
        snapshot.appendItems(recipeStore.recipeItems, toSection: .recipes)
        snapshot.appendItems(recipeStore.settingsItems, toSection: .settings)
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
        if editingStyle == .delete, indexPath.section == 0, let item = itemIdentifier(for: indexPath) {
            var snapshot = self.snapshot()
            snapshot.deleteItems([item])
            apply(snapshot, animatingDifferences: true) {
                self.deleteRecipe(item.id)
            }
        }
    }
    
    private func deleteRecipe(_ id: UUID) {
        if let index = recipeStore.recipes.firstIndex(where: { $0.id == id }) {
            self.recipeStore.deleteRecipe(at: index)
        }
    }
    
    // moving recipes
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard destinationIndexPath.row > recipeStore.recipes.count else { reset(); return }
        guard destinationIndexPath.section == 0 else { reset(); return}
        guard recipeStore.recipes.count > sourceIndexPath.row else { reset(); return }
        recipeStore.moveRecipe(from: sourceIndexPath.row, to: destinationIndexPath.row)
        reloadRecipes()
    }
    
    //wether a row can be deleted or not
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if itemIdentifier(for: indexPath) as? RecipeItem != nil {
            return true
        } else {return false}
    }
    
    //wether a row can be moved or not
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            return true
        } else {return false}
    }

}
