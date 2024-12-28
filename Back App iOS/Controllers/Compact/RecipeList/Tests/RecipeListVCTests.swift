//
//  RecipeListVCTests.swift
//  Back App iOSTests
//
//  Created by Moritz Schaub on 30.09.21.
//  Copyright © 2021 Moritz Schaub. All rights reserved.
//

import XCTest
import BackAppCore
import BakingRecipeStrings
import Combine
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
        window.makeKeyAndVisible()
        window.rootViewController = sut.navigationController!

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
            XCTAssertEqual(leadingButtons.count, 2)

            //settings button
            let settingsButton = leadingButtons.first!
            XCTAssertEqual(settingsButton.image, UIImage(systemName: "gear"))

            self.sut.perform(settingsButton.action)

            //editButton
            let editButton = leadingButtons.last!
            XCTAssertEqual(editButton.title, Strings.EditButton_Edit)

            XCTAssertEqual(self.sut.isEditing, false)
            self.sut.perform(editButton.action)
            XCTAssertEqual(self.sut.isEditing, true)
            self.sut.perform(editButton.action)
            XCTAssertEqual(self.sut.isEditing, false)

            //trailing
            let plusButton = navigationItem.rightBarButtonItem!
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

                importAction.handler(importAction)
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
