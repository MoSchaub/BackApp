// Copyright © 2022 Moritz Schaub. All rights reserved.
// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import BackAppCore
import BakingRecipeFoundation

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
        showRecipeDetail(for: item.recipe, sender: recipeListViewController)
    }

    /// shows the detail screen of `recipe` in the split view's secondary column
    func showRecipeDetail(for recipe: Recipe, sender: Any? = nil, animated: Bool = true) {
        let recipeId = recipe.id!
        let recipeViewController = RecipeDetailViewController(
            recipeId: recipeId, editVC: editRecipeViewController(for: recipeId),
            recipeName: recipe.formattedName)

        //show the viewController wrapped in a navigationController
        let navigationController = UINavigationController(rootViewController: recipeViewController)
        if animated {
            splitViewController.showDetailViewController(navigationController, sender: sender)
        } else {
            UIView.performWithoutAnimation {
                splitViewController.showDetailViewController(navigationController, sender: sender)
            }
        }
    }
}
