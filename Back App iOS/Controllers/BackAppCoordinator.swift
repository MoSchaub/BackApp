//
//  BackAppCoordinator.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 09.10.22.
//  Copyright © 2022 Moritz Schaub. All rights reserved.
//

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

        self.navigationController = UINavigationController()

        self.splitViewController = BASplitViewController()
        splitViewController.viewControllers = [navigationController]
        splitViewController.preferredDisplayMode = .allVisible

        self.appData = BackAppData.shared
    }

    func start() {
        window.rootViewController = splitViewController

        let recipeListCoordinator = RecipeListCoordinator(navigationController: navigationController)
        recipeListCoordinator.delegate = self
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
