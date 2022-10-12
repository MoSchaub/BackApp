//
//  RecipeListCoordinator.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 09.10.22.
//  Copyright © 2022 Moritz Schaub. All rights reserved.
//

import Foundation
import BackAppCore

final class RecipeListCoordinator: Coordinator {

    var navigationController: UINavigationController

    var childCoordinators = [Coordinator]()

    var delegate: RecipeListCoordinatorDelegate?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        if let appData = self.delegate?.appData {
            let recipeListVC = RecipeListViewController(appData: appData)
            navigationController.pushViewController(recipeListVC, animated: false)
        } else {
            //push to error controller
        }
    }

    func stop() {}
}

protocol RecipeListCoordinatorDelegate: AnyObject {
    var appData: BackAppData {get}
}
