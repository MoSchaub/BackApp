//
//  HomeDataSource.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 11.08.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import UIKit

extension UITableViewCell {
    func setupPlainCell(text: String) {
        let color = UIColor(named: Strings.backgroundColorName)!
        let image = UIImage(systemName: "chevron.up")
        image?.applyingSymbolConfiguration(.init(textStyle: .body, scale: .large))
        
        textLabel?.text = text
        backgroundColor = color
        accessoryView = UIImageView(image: image)
        accessoryView?.tintColor = .label
        selectionStyle = .none
    }
    
    func setupDetailCell(detailItem: DetailItem) {
        textLabel?.text = detailItem.text
        detailTextLabel?.attributedText = NSAttributedString(string: detailItem.detailLabel, attributes: [.foregroundColor : UIColor.label])
    }
}

class HomeDataSource: UITableViewDiffableDataSource<HomeSection,TextItem> {
    // storage object for recipes
    var recipeStore: RecipeStore

    init(recipeStore: RecipeStore, tableView: UITableView) {
        self.recipeStore = recipeStore
        
        super.init(tableView: tableView) { (_, indexPath, homeItem) -> UITableViewCell? in
            // Configuring cells
            if let recipeItem = homeItem as? RecipeItem, let recipeCell = tableView.dequeueReusableCell(withIdentifier: Strings.recipeCell, for: indexPath) as? RecipeTableViewCell {
                //recipeCell
                recipeCell.setUp(cellData: .init(name: recipeItem.text, minuteLabel: recipeItem.minuteLabel, imageData: recipeItem.imageData))
                return recipeCell
            } else if let detailItem = homeItem as? DetailItem {
                // Detail Cell (RoomTemp und About)
                let cell = tableView.dequeueReusableCell(withIdentifier: Strings.detailCell, for: indexPath)
                cell.setupDetailCell(detailItem: detailItem)
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
                let _ = self.deleteRecipe(item.id)
            }
        }
    }
    
    func deleteRecipe(_ id: UUID) -> Bool {
        if let index = recipeStore.recipes.firstIndex(where: { $0.id == id }) {
            return self.recipeStore.deleteRecipe(at: index)
        } else { return false }
    }
    
    // moving recipes
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard destinationIndexPath.row < recipeStore.recipes.count else { reset(); return }
        guard destinationIndexPath.section == 0 else { reset(); return}
        guard recipeStore.recipes.count > sourceIndexPath.row else { reset(); return }
        DispatchQueue.global(qos: .userInteractive).async {
            self.recipeStore.moveRecipe(from: sourceIndexPath.row, to: destinationIndexPath.row)
            DispatchQueue.main.async {
                self.update(animated: false)
            }
        }

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
