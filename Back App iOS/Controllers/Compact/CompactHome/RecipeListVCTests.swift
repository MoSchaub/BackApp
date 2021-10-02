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

class RecipeListVCTests: XCTestCase {

    var sut: RecipeListViewController!

    var appData: BackAppData!

    var subscribers: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()

        appData = BackAppData.shared(includeTestingRecipe: true)
        sut = RecipeListViewController(appData: appData)
        _ = UINavigationController(rootViewController: sut)

        fixWindow()

        if let subscribers = subscribers {
            _ = subscribers.map { $0.cancel() }
        }
        subscribers = Set<AnyCancellable>()

        let recipeListAvailableExpectation = self.expectation(description: "recipeListAvailable")

        NotificationCenter.default.publisher(for: .recipeListVCAvailable, object: nil)
            .sink { _ in
                recipeListAvailableExpectation.fulfill()
            }.store(in: &subscribers)

        waitForExpectations(timeout: 10)

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

}
