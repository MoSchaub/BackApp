// Copyright © 2021 Moritz Schaub. All rights reserved.
// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import XCTest
import BackAppCore
import BakingRecipeStrings
import Combine
import UIKit
@testable import Back_App

class MockDelegate: RecipeListViewDelegate {
    func navigateToSettings(from recipeListViewController: Back_App.RecipeListViewController) {
        
    }
    
    func navigateToRecipeDetail(from recipeListViewController: Back_App.RecipeListViewController, with: BackAppCore.BackAppData.RecipeListItem) {
        
    }
    
    func presentNewRecipePopover(from recipeListViewController: Back_App.RecipeListViewController) {
        
    }
    
    func presentRoomTempSheet(from recipeListViewController: Back_App.RecipeListViewController) {
        
    }
    
    func presentImportAlert(from recipeListViewController: Back_App.RecipeListViewController) {
        
    }
    
    func editRecipeViewController(for recipeId: Int64) -> Back_App.EditRecipeViewController {
        return EditRecipeViewController(recipeId: recipeId, creating: false, appData: BackAppData.shared(includeTestingRecipe: true))
    }
    
    
}

class RecipeListVCTests: XCTestCase {

    var sut: RecipeListViewController!

    var appData: BackAppData!

    var subscribers: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()

        appData = BackAppData.shared(includeTestingRecipe: true)
        

        sut = RecipeListViewController(appData: appData, delegate: MockDelegate())
        _ = UINavigationController(rootViewController: sut)

        fixWindow()

        if let subscribers = subscribers {
            _ = subscribers.map { $0.cancel() }
        }
        subscribers = Set<AnyCancellable>()
    }

    func fixWindow() {
        //fix window
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = sut.navigationController!
        window.makeKeyAndVisible()
        _ = self.sut.navigationController?.view

        _ = sut.view
        sut.viewDidLoad()
    }

    func contextMenu() -> UIMenu? {
        let indexPath = IndexPath(row: 0, section: 0)
        return try? XCTUnwrap(self.sut.contextMenu(indexPath: indexPath))
    }


    func test_contextMenu() {

        let expectation = self.expectation(description: "expectation")
        DispatchQueue.main.async {
            XCTAssertEqual(self.contextMenu()?.children.count, 6)

            let childStatsArray = [
                ChildStats(image: UIImage(systemName: "play"), title: Strings.startRecipe, attributes: .init(rawValue: 0)),
                ChildStats(image: UIImage(systemName: "pencil"), title: Strings.EditButton_Edit, attributes: .init(rawValue: 0)),
                ChildStats(image: UIImage(systemName: "square.and.arrow.up"), title: Strings.share, attributes: .init(rawValue: 0)),
                ChildStats(image: UIImage(systemName: "square.on.square"), title: Strings.duplicate, attributes: .init(rawValue: 0)),
                ChildStats(image: UIImage(systemName: "star"), title: Strings.addFavorite, attributes: .init(rawValue: 0)),
                ChildStats(image: UIImage(systemName: "trash"), title: Strings.Alert_ActionDelete, attributes: .destructive)
            ]
            for i in 0..<childStatsArray.count {
                self.testChild(childStats: childStatsArray[i], index: i)
            }


            expectation.fulfill()
        }
        waitForExpectations(timeout: 10)
    }

    struct ChildStats {
        let image: UIImage?
        let title: String
        let attributes: UIMenu.Attributes
    }

    func testChild(childStats: ChildStats, index: Int) {
        let child = self.contextMenu()?.children[index] as! UIAction
        XCTAssertEqual(child.image, childStats.image)
        XCTAssertEqual(child.title, childStats.title)
        XCTAssertEqual(child.attributes, childStats.attributes)

        child.handler(child)
    }

    func test_navigationBar() {

        let expectation = self.expectation(description: "")

        sut.configureNavigationBar {
            //title
            XCTAssertEqual(self.sut.title, Strings.recipes)

            let navigationItem = self.sut.navigationItem

            //leading
            let leadingButtons = navigationItem.leftBarButtonItems ?? []
            XCTAssertEqual(leadingButtons.count, 1)

            //settings button
            let settingsButton = leadingButtons.first!
            XCTAssertEqual(settingsButton.image, UIImage(systemName: "gear"))

            self.sut.perform(settingsButton.action)

            let trailingButtons = navigationItem.rightBarButtonItems ?? []
            XCTAssertGreaterThanOrEqual(trailingButtons.count, 2)

            let editButton: UIBarButtonItem = {
                if let found = trailingButtons.first(where: { $0.title == Strings.EditButton_Edit || $0.title == Strings.EditButton_Done }) {
                    return found
                }
                return trailingButtons.last!
            }()

            XCTAssertEqual(self.sut.isEditing, false)
            if let title = editButton.title {
                XCTAssertEqual(title, Strings.EditButton_Edit)
            }

            if let action = editButton.action, let target = editButton.target as AnyObject? {
                _ = target.perform(action, with: editButton)
            } else {
                self.sut.setEditing(true, animated: false)
            }
            XCTAssertEqual(self.sut.isEditing, true)
            if let title = editButton.title {
                XCTAssertEqual(title, Strings.EditButton_Done)
            }

            if let action = editButton.action, let target = editButton.target as AnyObject? {
                _ = target.perform(action, with: editButton)
            } else {
                self.sut.setEditing(false, animated: false)
            }
            XCTAssertEqual(self.sut.isEditing, false)
            if let title = editButton.title {
                XCTAssertEqual(title, Strings.EditButton_Edit)
            }

            //trailing
            let plusButton = trailingButtons.first!
            XCTAssertEqual(plusButton.image, UIImage(systemName: "plus"))

            if #available(iOS 14.0, *) {

                plusButton.primaryAction!.handler(plusButton.primaryAction!)

                let menu = plusButton.menu
                XCTAssertEqual(menu?.children.count, 2)

                let plusAction = menu?.children.first as! UIAction
                XCTAssertEqual(plusAction.image, UIImage(systemName: "plus"))
                XCTAssertEqual(plusAction.title, Strings.addRecipe)

                plusAction.handler(plusAction)

                let importAction = menu?.children.last as! UIAction
                XCTAssertEqual(importAction.image, nil)
                XCTAssertEqual(importAction.title, Strings.importFile)

                // Invoke the import action via a test-only selector to avoid directly calling the UIAction handler
                self.sut.perform(#selector(RecipeListViewController._test_openImportFilePopover))
            }

            //search
            XCTAssertNotNil(navigationItem.searchController)
            guard let searchController = navigationItem.searchController else {
                return
            }

            XCTAssertEqual(searchController.hidesNavigationBarDuringPresentation, true)
            XCTAssertEqual(searchController.obscuresBackgroundDuringPresentation, false)

            expectation.fulfill()
        }

        waitForExpectations(timeout: 10)
    }

}

