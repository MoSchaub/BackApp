//
//  RecipeDetailDataSource.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 11.08.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI
import BakingRecipe

class RecipeDetailDataSource: UITableViewDiffableDataSource<RecipeDetailSection, Item> {
    
    @Binding var recipe: Recipe
    let creating: Bool
    
    init(recipe: Binding<Recipe>, creating: Bool, tableView: UITableView, nameChanged: @escaping (String) -> (), formatAmount: @escaping (String) -> (String)) {
        self._recipe = recipe
        self.creating = creating
        super.init(tableView: tableView) { (_, indexPath, item) -> UITableViewCell? in
            if let _ = item as? TextFieldItem, let cell = tableView.dequeueReusableCell(withIdentifier: "textField", for: indexPath) as? TextFieldTableViewCell {
                cell.textField.text = recipe.wrappedValue.name
                cell.textField.placeholder = NSLocalizedString("name", comment: "")
                cell.selectionStyle = .none
                cell.textChanged = nameChanged
                return cell
            } else if let imageItem = item as? ImageItem, let imageCell = tableView.dequeueReusableCell(withIdentifier: "image", for: indexPath) as? ImageTableViewCell {
                imageCell.setup(imageData: imageItem.imageData)
                return imageCell
            } else if let _ = item as? AmountItem, let amountCell = tableView.dequeueReusableCell(withIdentifier: "times", for: indexPath) as? AmountTableViewCell{
                amountCell.setUp(with: recipe.wrappedValue.timesText, format: formatAmount)
                return amountCell
            } else if let infoItem = item as? InfoItem {
                let cell = tableView.dequeueReusableCell(withIdentifier: "plain", for: indexPath)
                cell.textLabel?.text = infoItem.text
                return cell
            } else if let stripItem = item as? InfoStripItem, let infoStripCell = tableView.dequeueReusableCell(withIdentifier: "infoStrip", for: indexPath) as? InfoStripTableViewCell {
                infoStripCell.setUpCell(for: stripItem)
                return infoStripCell
            } else if let stepItem = item as? StepItem {
                let stepCell = StepTableViewCell(style: .default, reuseIdentifier: "step")
                stepCell.setUpCell(for: stepItem.step)
                return stepCell
            } else if let detailItem = item as? DetailItem, let cell = tableView.dequeueReusableCell(withIdentifier: "detail", for: indexPath) as? DetailTableViewCell {
                let title = NSAttributedString(string: detailItem.text, attributes: [.foregroundColor : UIColor.link])
                cell.textLabel?.attributedText = title
                cell.accessoryType = .disclosureIndicator
                return cell
            }
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return NSLocalizedString("name", comment: "")
        case 1: return NSLocalizedString("bild", comment: "")
        case 2: return NSLocalizedString("anzahl", comment: "")
        case 3: return "info"
        default: return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        (itemIdentifier(for: indexPath) as? StepItem) != nil
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        itemIdentifier(for: indexPath) as? StepItem != nil
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete, let item = itemIdentifier(for: indexPath) as? StepItem {
            var snapshot = self.snapshot()
            snapshot.deleteItems([item])
            apply(snapshot, animatingDifferences: true) {
                self.deleteStep(item.id)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard destinationIndexPath.row < recipe.steps.count else { reset(tableView: tableView, indexPath: sourceIndexPath); return }
        guard destinationIndexPath.section == 5 else { reset(tableView: tableView, indexPath: sourceIndexPath); return}
        guard recipe.steps.count > sourceIndexPath.row else { reset(tableView: tableView, indexPath: sourceIndexPath); return }
        recipe.moveSteps(from: sourceIndexPath.row, to: destinationIndexPath.row)
    }
    
}

extension RecipeDetailDataSource {
    func update(animated: Bool) {
        var snapshot = NSDiffableDataSourceSnapshot<RecipeDetailSection, Item>()
        snapshot.appendSections(RecipeDetailSection.allCases)
        snapshot.appendItems([recipe.nameItem()], toSection: .name)
        snapshot.appendItems([recipe.imageItem], toSection: .image)
        snapshot.appendItems([recipe.amountItem()], toSection: .times)
        snapshot.appendItems([recipe.infoItem], toSection: .info)
        snapshot.appendItems(recipe.controlStripItems(creating: self.creating), toSection: .controlStrip)
        snapshot.appendItems(recipe.stepItems, toSection: .steps)
        snapshot.appendItems([DetailItem(name: "Schritt hinzufügen", detailLabel: "")],toSection: .steps)
        apply(snapshot, animatingDifferences: animated)
    }
    
    func reloadSteps() {
        var snapshot = self.snapshot()
        snapshot.reloadSections([.steps])
        self.apply(snapshot)
    }
    
    private func reset(tableView: UITableView, indexPath: IndexPath) {
        var snapshot = self.snapshot()
        snapshot.deleteAllItems()
        self.apply(snapshot, animatingDifferences: false)
        self.update(animated: false)
        tableView.scrollToRow(at: indexPath, at: .middle, animated: false)
    }
    
    private func deleteStep(_ id: UUID) {
        if let index = recipe.steps.firstIndex(where: { $0.id == id }) {
            self.recipe.steps.remove(at: index)
        }
    }
}
