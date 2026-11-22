// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import UIKit
import BackAppCore

protocol BackAppCoordinatorDelegate {
    func cordinatorDidCompleteStart()
}

final class BackAppCoordinator: NSObject, Coordinator, RecipeListCoordinatorDelegate {

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
        } else {
            self.splitViewController = BASplitViewController()
        }

        self.appData = BackAppData.shared
        super.init()

        splitViewController.preferredDisplayMode = .oneBesideSecondary
        if #available(iOS 26.0, *) {
            splitViewController.displayModeButtonVisibility = .never
        }

        // show a placeholder in the detail column until a recipe is selected
        let placeholder = Self.makePlaceholder()
        if splitViewController.style == .unspecified {
            splitViewController.viewControllers = [navigationController, placeholder]
        } else {
            splitViewController.setViewController(navigationController, for: .primary)
            splitViewController.setViewController(placeholder, for: .secondary)
        }
        splitViewController.delegate = self
    }

    /// The placeholder for the split view's detail column, wrapped in a navigation controller like the recipe detail
    static func makePlaceholder() -> UINavigationController {
        UINavigationController(rootViewController: RecipePlaceholderViewController())
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


    /// shows the recipe described by a state restoration activity, if it still exists
    func restoreState(from activity: NSUserActivity?) {
        guard let recipe = appData.recipeToRestore(from: activity),
              let recipeListCoordinator = childCoordinators.lazy.compactMap({ $0 as? RecipeListCoordinator }).first
        else { return }

        recipeListCoordinator.showRecipeDetail(for: recipe, animated: false)
    }

    /// imports the recipe files at the given urls
    public func open(urls: [URL]) {
        for url in urls {
            appData.open(url)
        }
    }

    public func getWindow() -> UIWindow {
        return self.window
    }

    func stop() {}
    
}

// MARK: - Split view

extension BackAppCoordinator: UISplitViewControllerDelegate {

    private func isPlaceholder(_ viewController: UIViewController?) -> Bool {
        (viewController as? UINavigationController)?.viewControllers.first is RecipePlaceholderViewController
            || viewController is RecipePlaceholderViewController
    }

    // Column style (iOS 26+): when the split view collapses (iPhone, folding the Duo, narrow iPad window),
    // show the recipe list instead of the placeholder.
    func splitViewController(_ svc: UISplitViewController,
                             topColumnForCollapsingToProposedTopColumn proposedTopColumn: UISplitViewController.Column) -> UISplitViewController.Column {
        isPlaceholder(svc.viewController(for: .secondary)) ? .primary : proposedTopColumn
    }

    // Classic style: drop the placeholder when collapsing instead of pushing it onto the list
    func splitViewController(_ splitViewController: UISplitViewController,
                             collapseSecondary secondaryViewController: UIViewController,
                             onto primaryViewController: UIViewController) -> Bool {
        isPlaceholder(secondaryViewController)
    }

    // Classic style: when expanding with only the list on screen, show the placeholder next to it
    func splitViewController(_ splitViewController: UISplitViewController,
                             separateSecondaryFrom primaryViewController: UIViewController) -> UIViewController? {
        guard let primary = primaryViewController as? UINavigationController, primary.viewControllers.count <= 1 else {
            return nil
        }
        return Self.makePlaceholder()
    }
}
