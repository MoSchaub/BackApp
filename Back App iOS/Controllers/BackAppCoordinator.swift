// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import UIKit
import BackAppCore

protocol BackAppCoordinatorDelegate {
    func cordinatorDidCompleteStart()
}

final class BackAppCoordinator: Coordinator, RecipeListCoordinatorDelegate {

    var childCoordinators: [Coordinator] = []

    private let splitViewController: BASplitViewController

    var navigationController: UINavigationController

    internal var appData: BackAppData

    private let window: UIWindow

    init(windowScene: UIWindowScene) {
        self.window = UIWindow(windowScene: windowScene)

        //the navigation controller is needed to make the title and navbar work
        self.navigationController = UINavigationController()
        
        if #available(iOS 26.0, *) {
            self.splitViewController = BASplitViewController(style: UISplitViewController.Style.doubleColumn)
            splitViewController.preferredDisplayMode = .oneBesideSecondary
            splitViewController.displayModeButtonVisibility = .never
        } else {
            self.splitViewController = BASplitViewController()
            if #available(iOS 14.0, *) {
                splitViewController.preferredDisplayMode = .oneBesideSecondary
            } else {
                splitViewController.preferredDisplayMode = .allVisible
            }
        }
        
        splitViewController.viewControllers = [navigationController]

        self.appData = BackAppData.shared
    }

    func start() {
        window.rootViewController = splitViewController

        let recipeListCoordinator = RecipeListCoordinator(navigationController: navigationController,
                                                          splitViewController: splitViewController,
                                                          delegate: self)
        recipeListCoordinator.start()
        add(childCoordinator: recipeListCoordinator)

        window.makeKeyAndVisible()
        window.tintColor = UIColor.baTintColor //needs to be called after making the window visible
    }


    public func open(URLContexts: Set<UIOpenURLContext>) {
        let urls = URLContexts.map { $0.url}
        for url in urls {
            appData.open(url)
        }
    }

    public func getWindow() -> UIWindow {
        return self.window
    }

    func stop() {}
    
}

