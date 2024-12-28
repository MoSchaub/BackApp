// Copyright © 2022 Moritz Schaub. All rights reserved.
// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import BackAppCore

extension RecipeListCoordinator {
    func navigateToSettings(from recipeListViewController: RecipeListViewController) {
        let settingsViewController = SettingsViewController(appData: delegate.appData)

        // a brand new navigation Controller since the RecipeDetail should use a diffrent Navigation Stack than the List
        let navigationController = UINavigationController(rootViewController: settingsViewController)

        self.splitViewController.showDetailViewController(navigationController, sender: self)
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
