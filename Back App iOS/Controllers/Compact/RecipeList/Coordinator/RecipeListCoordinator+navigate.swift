// Copyright © 2022 Moritz Schaub. All rights reserved.
// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import BackAppCore

extension RecipeListCoordinator {
    func navigateToSettings(from recipeListViewController: RecipeListViewController) {
        let settingsViewController = SettingsViewController(appData: delegate.appData)

        // Present settings modally in its own navigation controller as a sheet
        let navigationController = UINavigationController(rootViewController: settingsViewController)
        if #available(iOS 15.0, *) {
            navigationController.sheetPresentationController?.detents = [.medium(), .large()]
        }
        navigationController.modalPresentationStyle = .pageSheet

        recipeListViewController.present(navigationController, animated: true)
    }

    func navigateToRecipeDetail(from recipeListViewController: RecipeListViewController, with item: BackAppData.RecipeListItem) {
        DispatchQueue.main.async { //needs to be on main thread
            let recipeId = item.recipe.id!
            let recipeViewController = RecipeDetailViewController(
                recipeId: recipeId, editVC: self.editRecipeViewController(for: recipeId),
                recipeName: item.recipe.formattedName)

            //show the viewController wrapped in a navigationController
            let navigationController = UINavigationController(rootViewController: recipeViewController)
            self.splitViewController.showDetailViewController(navigationController, sender: recipeListViewController)
        }
    }
}
