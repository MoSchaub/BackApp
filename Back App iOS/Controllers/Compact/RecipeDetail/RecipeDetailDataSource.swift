//
//  RecipeDetailDataSource.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 11.08.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI
import BakingRecipeFoundation
import BakingRecipeItems
import BakingRecipeStrings
import BakingRecipeSections
import BakingRecipeCells
import BackAppCore

class RecipeDetailDataSource: UITableViewDiffableDataSource<RecipeDetailSection, Item> {
    
    @Binding var recipe: Recipe
    let creating: Bool
    let appData: BackAppData
    
    init(recipe: Binding<Recipe>, creating: Bool, appData: BackAppData ,tableView: UITableView, nameChanged: @escaping (String) -> (), formatAmount: @escaping (String) -> (String), updateInfo: @escaping (String) -> () ) {
        self._recipe = recipe
        self.creating = creating
        self.appData = appData
        super.init(tableView: tableView) { (tableView, indexPath, item) -> UITableViewCell? in
            //let color = UIColor.cellBackgroundColor
            if let _ = item as? TextFieldItem, let cell = tableView.dequeueReusableCell(withIdentifier: Strings.textFieldCell, for: indexPath) as? TextFieldCell {
                cell.textField.text = recipe.wrappedValue.name
                cell.textField.attributedPlaceholder = NSAttributedString(string: Strings.name, attributes: [.foregroundColor : UIColor.secondaryCellTextColor!])
                cell.selectionStyle = .none
                cell.textChanged = nameChanged
                return cell
            } else if let imageItem = item as? ImageItem{
                let imageCell = ImageCell(reuseIdentifier: Strings.imageCell, data: imageItem.imageData)
                return imageCell
            } else if let _ = item as? AmountItem, let amountCell = tableView.dequeueReusableCell(withIdentifier: Strings.amountCell, for: indexPath) as? AmountCell{
                amountCell.setUp(with: recipe.wrappedValue.timesText, format: formatAmount)
                return amountCell
            } else if item is InfoItem {
                return TextViewCell(textContent: Binding(get: {
                    return recipe.wrappedValue.info
                }, set: updateInfo), placeholder: Strings.info, reuseIdentifier: Strings.infoCell)
            } else if let stripItem = item as? InfoStripItem, let infoStripCell = tableView.dequeueReusableCell(withIdentifier: Strings.infoStripCell, for: indexPath) as? InfoStripCell {
                infoStripCell.setUpCell(for: stripItem)
                return infoStripCell
            } else if let stepItem = item as? StepItem {
                let stepCell = StepCell(step: stepItem.step, reuseIdentifier: Strings.stepCell)
                return stepCell
            } else if let detailItem = item as? DetailItem, let cell = tableView.dequeueReusableCell(withIdentifier: Strings.detailCell, for: indexPath) as? DetailCell {
                cell.textLabel?.text = detailItem.text
                cell.accessoryType = .disclosureIndicator
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
        if let stepItem = itemIdentifier(for: indexPath) as? StepItem, let step = appData.object(with: stepItem.id, of: Step.self), step.superStepId == nil {
            return true
        }
        return false
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
        let steps = appData.steps(with: recipe.id)
        guard destinationIndexPath.row < steps.count else { reset(tableView: tableView, indexPath: sourceIndexPath); return }
        guard RecipeDetailSection.allCases[destinationIndexPath.section] == .steps  else { reset(tableView: tableView, indexPath: sourceIndexPath); return}
        guard steps.count > sourceIndexPath.row else { reset(tableView: tableView, indexPath: sourceIndexPath); return }

        appData.moveStep(with: recipe.id, from: sourceIndexPath.row, to: destinationIndexPath.row)
        update(animated: false)
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
    
    private func deleteStep(_ id: Int) {
        if let step = appData.steps(with: recipe.id).first(where: { $0.id == id }) {
            _ = appData.delete(step)
        }
    }
}
