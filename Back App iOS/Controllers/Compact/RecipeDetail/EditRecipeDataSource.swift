//
//  EditRecipeDataSource.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 11.08.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI
import BackAppCore
import BakingRecipeFoundation
import BakingRecipeStrings
import BackAppCore

extension NSNotification.Name {
    static var editRecipeShouldUpdate = NSNotification.Name.init(rawValue: "editRecipeShouldUpdate")
    static var specialNavbarShouldShow = NSNotification.Name.init(rawValue: "specialNavbarShouldShow")
}

class EditRecipeDataSource: UITableViewDiffableDataSource<RecipeDetailSection, Item> {

    public var recipeId: Int64!
    
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
        if let item = itemIdentifier(for: indexPath) as? StepItem, let step = BackAppData.shared.record(with: Int64(item.id), of: Step.self), step.superStepId == nil {
            return true
        } else {
            return false
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete, let item = itemIdentifier(for: indexPath) as? StepItem {
            var snapshot = self.snapshot()
            snapshot.deleteItems([item])
            apply(snapshot, animatingDifferences: true) {
                try? BackAppData.shared.dbWriter.write { db in
                    _ = try Step.deleteOne(db, id: Int64(item.id))
                }
            }
        }
    }
    
    /// move steps
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let appData = BackAppData.shared
        let steps = appData.steps(with: recipeId)
        guard destinationIndexPath.row < steps.count else { reset(tableView: tableView, indexPath: sourceIndexPath); return }
        guard RecipeDetailSection.allCases[destinationIndexPath.section] == .steps  else { reset(tableView: tableView, indexPath: sourceIndexPath); return}
        guard steps.count > sourceIndexPath.row else { reset(tableView: tableView, indexPath: sourceIndexPath); return }

        appData.moveStep(with: recipeId, from: sourceIndexPath.row, to: destinationIndexPath.row)
    }
    
}

extension EditRecipeDataSource {
    private func reset(tableView: UITableView, indexPath: IndexPath) {
        var snapshot = self.snapshot()
        snapshot.deleteAllItems()
        self.apply(snapshot, animatingDifferences: false)
        NotificationCenter.default.post(name: .editRecipeShouldUpdate, object: nil)
        tableView.scrollToRow(at: indexPath, at: .middle, animated: false)
    }
}
