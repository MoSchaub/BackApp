//
//  RecipeListCoordinator.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 09.10.22.
//  Copyright © 2022 Moritz Schaub. All rights reserved.
//

final class RecipeListCoordinator: Coordinator {

    var navigationController: UINavigationController

    var splitViewController: BASplitViewController

    var childCoordinators = [Coordinator]()

    let delegate: RecipeListCoordinatorDelegate

    init(navigationController: UINavigationController, splitViewController: BASplitViewController,
         delegate: RecipeListCoordinatorDelegate) {
        self.navigationController = navigationController
        self.splitViewController = splitViewController
        self.delegate = delegate
    }

    func start() {
        let recipeListVC = RecipeListViewController(appData: delegate.appData, delegate: self)
        navigationController.pushViewController(recipeListVC, animated: false)
    }

    func stop() {}
}

extension RecipeListCoordinator: RecipeListViewDelegate {

    func editRecipeViewController(for recipeId: Int64) -> EditRecipeViewController {
        EditRecipeViewController(recipeId: recipeId, creating: false, appData: delegate.appData) {

            // Dismiss detail closure used if recipe is deleted
            if self.splitViewController.isCollapsed {
                // splitViewController is collapsed so we need to pop our viewController from the navigation Stack
                self.navigationController.popViewController(animated: true)
            } else {
                // otherwise we need to pop the detail viewController
                NotificationCenter.default.post(name: .homeShouldPopSplitVC, object: nil)
            }
        }
    }

}
