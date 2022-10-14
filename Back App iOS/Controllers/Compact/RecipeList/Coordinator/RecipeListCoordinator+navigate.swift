//
//  RecipeListCoordinator+navigate.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 13.10.22.
//  Copyright © 2022 Moritz Schaub. All rights reserved.
//

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
