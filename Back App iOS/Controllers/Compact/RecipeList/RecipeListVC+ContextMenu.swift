// Copyright © 2022 Moritz Schaub. All rights reserved.
// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import BakingRecipeStrings

extension RecipeListViewController {

    internal func contextMenu(indexPath: IndexPath) -> UIMenu? {
        guard let recipe = self.dataSource.itemIdentifier(for: indexPath)?.recipe else {
            return nil
        }

        // toggle favourite for the recipe
        let favourite = UIAction(title: recipe.isFavorite ? Strings.removeFavorite : Strings.addFavorite, image: UIImage(systemName: recipe.isFavorite ? "star.slash" : "star")) { action in
            var recipe = recipe
            self.appData.toggleFavorite(for: &recipe)
            NotificationCenter.default.post(name: .recipesChanged, object: nil)
        }

        // pull up the share recipe sheet
        let share = UIAction(title: Strings.share, image: UIImage(systemName: "square.and.arrow.up")) { action in
            let vc = UIActivityViewController(activityItems: [self.appData.exportRecipesToFile(recipes: [recipe])], applicationActivities: nil)
            vc.popoverPresentationController?.sourceView = self.tableView.cellForRow(at: indexPath)
            self.present(vc, animated: true)
        }

        // delete the recipe
        let delete = UIAction(title: Strings.Alert_ActionDelete, image: UIImage(systemName: "trash"), attributes: .destructive ) { action in
            self.appData.delete(recipe)
        }

        // jump to editRecipeVC
        let edit = UIAction(title: Strings.EditButton_Edit, image: UIImage(systemName: "pencil")) { action in
            let navigationController = UINavigationController(rootViewController: self.delegate.editRecipeViewController(for: recipe.id!))
            self.splitViewController?.showDetailViewController(navigationController, sender: self)
        }

        // jump to scheduleForm
        let start = UIAction(title: Strings.startRecipe, image: UIImage(systemName: "play")) { action in

            let scheduleFormVC = ScheduleFormViewController(recipe: try! self.appData.recordBinding(for: recipe), appData: self.appData)

            let nv = UINavigationController(rootViewController: scheduleFormVC)

            self.splitViewController?.showDetailViewController(nv, sender: self)
        }

        let dupeAction = UIAction(title: Strings.duplicate, image: UIImage(systemName: "square.on.square")) { action in
            recipe.duplicate(writer: self.appData.dbWriter)
        }

        return UIMenu(title: recipe.name, children: [start, edit, share, dupeAction, favourite, delete])
    }

    /// creates a contextMenu for the recipe Cell
    private func contextMenuConfig(at indexPath: IndexPath) -> UIContextMenuConfiguration? {

        let actionProvider: UIContextMenuActionProvider = { (suggestedActions) in
            self.contextMenu(indexPath: indexPath)
        }

        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: actionProvider)
    }

    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return contextMenuConfig(at: indexPath)
    }
}
