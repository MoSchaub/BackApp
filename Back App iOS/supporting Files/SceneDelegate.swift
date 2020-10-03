//
//  SceneDelegate.swift
//  Back App iOS
//
//  Created by Franka Schaub on 26.06.20.
//  Copyright © 2020 Franka Schaub. All rights reserved.
//

import UIKit
import BakingRecipeCore

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    let recipeStore = RecipeStore()
    lazy var compactHomeVC = CompactHomeViewController(recipeStore: recipeStore)

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        let splitViewController = UISplitViewController()
        
        let navigationViewController = UINavigationController(rootViewController: compactHomeVC)
        splitViewController.viewControllers = [navigationViewController]
        splitViewController.preferredDisplayMode = .allVisible
        window.rootViewController = splitViewController
        window.makeKeyAndVisible()
        self.window = window
        self.window!.tintColor = UIColor(named: Strings.backgroundColorName)!
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        recipeStore.update()
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        // open file in app
        let _ = URLContexts.map({ self.recipeStore.open($0.url, isArray: true); self.recipeStore.open($0.url, isArray: false) })
        compactHomeVC.dataSource.update(animated: true)
        
        let alert = UIAlertController(title: recipeStore.inputAlertTitle, message: recipeStore.inputAlertMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        compactHomeVC.present(alert, animated: true)
    }

}

