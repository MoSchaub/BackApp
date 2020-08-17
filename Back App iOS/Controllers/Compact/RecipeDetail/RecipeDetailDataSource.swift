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
    
    init(recipe: Binding<Recipe>, creating: Bool, tableView: UITableView, nameChanged: @escaping (String) -> (), formatAmount: @escaping (String) -> (String), updateInfo: @escaping (String) -> () ) {
        self._recipe = recipe
        self.creating = creating
        super.init(tableView: tableView) { (tableView, indexPath, item) -> UITableViewCell? in
            let color = UIColor(named: Strings.backgroundColorName)!
            if let _ = item as? TextFieldItem, let cell = tableView.dequeueReusableCell(withIdentifier: Strings.textFieldCell, for: indexPath) as? TextFieldTableViewCell {
                cell.textField.text = recipe.wrappedValue.name
                cell.textField.placeholder = Strings.name
                cell.selectionStyle = .none
                cell.textChanged = nameChanged
                cell.backgroundColor = color
                return cell
            } else if let imageItem = item as? ImageItem, let imageCell = tableView.dequeueReusableCell(withIdentifier: Strings.imageCell, for: indexPath) as? ImageTableViewCell {
                imageCell.setup(imageData: imageItem.imageData)
                return imageCell
            } else if let _ = item as? AmountItem, let amountCell = tableView.dequeueReusableCell(withIdentifier: Strings.amountCell, for: indexPath) as? AmountTableViewCell{
                amountCell.setUp(with: recipe.wrappedValue.timesText, format: formatAmount)
                amountCell.backgroundColor = color
                return amountCell
            } else if item is InfoItem {
                return InfoTableViewCell(infoText: Binding(get: {
                    return recipe.wrappedValue.info
                }, set: updateInfo), reuseIdentifier: Strings.infoCell)
            } else if let stripItem = item as? InfoStripItem, let infoStripCell = tableView.dequeueReusableCell(withIdentifier: Strings.infoStripCell, for: indexPath) as? InfoStripTableViewCell {
                infoStripCell.setUpCell(for: stripItem)
                return infoStripCell
            } else if let stepItem = item as? StepItem {
                let stepCell = StepTableViewCell(style: .default, reuseIdentifier: Strings.stepCell)
                stepCell.setUpCell(for: stepItem.step)
                return stepCell
            } else if let detailItem = item as? DetailItem, let cell = tableView.dequeueReusableCell(withIdentifier: Strings.detailCell, for: indexPath) as? DetailTableViewCell {
                let title = NSAttributedString(string: detailItem.text, attributes: [.foregroundColor : UIColor.label])
                cell.textLabel?.attributedText = title
                cell.accessoryType = .disclosureIndicator
                cell.backgroundColor = color
                return cell
            }
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return Strings.name
        case 2: return Strings.quantity
        case 4: return Strings.info
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
        guard RecipeDetailSection.allCases[destinationIndexPath.section] == .steps  else { reset(tableView: tableView, indexPath: sourceIndexPath); return}
        guard recipe.steps.count > sourceIndexPath.row else { reset(tableView: tableView, indexPath: sourceIndexPath); return }
    
        let stepToMove = recipe.steps.remove(at: sourceIndexPath.row)
        recipe.steps.insert(stepToMove, at: destinationIndexPath.row)
    }
    
}

extension RecipeDetailDataSource {
    func update(animated: Bool) {
        var snapshot = NSDiffableDataSourceSnapshot<RecipeDetailSection, Item>()
        snapshot.appendSections(RecipeDetailSection.allCases)
        snapshot.appendItems([recipe.nameItem()], toSection: .name)
        snapshot.appendItems([recipe.imageItem], toSection: .imageControlStrip)
        snapshot.appendItems(recipe.controlStripItems(creating: self.creating), toSection: .imageControlStrip)
        snapshot.appendItems([recipe.amountItem()], toSection: .times)
        snapshot.appendItems(recipe.stepItems, toSection: .steps)
        snapshot.appendItems([DetailItem(name: Strings.addStep, detailLabel: "")],toSection: .steps)
        snapshot.appendItems([recipe.infoItem], toSection: .info)
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
