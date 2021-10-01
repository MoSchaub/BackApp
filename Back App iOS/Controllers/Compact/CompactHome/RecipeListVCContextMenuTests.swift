//
//  RecipeListVCContextMenuTests.swift
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

class RecipeListVCContextMenuTests: XCTestCase {

    var sut: RecipeListViewController!

    var appData: BackAppData!

    var tokens: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        appData = BackAppData.shared(includeTestingRecipe: true)
        sut = RecipeListViewController(appData: appData)
        _ = UINavigationController(rootViewController: sut)

        fixWindow()

        tokens = Set<AnyCancellable>()

    }

    func fixWindow() {
        //fix window
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.makeKeyAndVisible()
        window.rootViewController = sut.navigationController!
    
        _ = sut.view
        sut.viewDidLoad()
    }

    func test_hasContextMenu() {

        let expectation = self.expectation(description: "exampleRecipe")

        NotificationCenter.default.publisher(for: .recipeListVCAvailable, object: nil)
            .sink { _ in

                expectation.fulfill()
            }.store(in: &tokens)

        waitForExpectations(timeout: 10)

        let indexPath = IndexPath(row: 0, section: 0)

        let secondexpectation = self.expectation(description: "2")
        DispatchQueue.main.async {
            let contextMenu = self.sut.contextMenu(indexPath: indexPath)
            XCTAssertNotNil(contextMenu)
            print(contextMenu!)
            XCTAssertEqual(contextMenu!.children.count, 6)

            //start
            let startChild = contextMenu!.children.first! as! UIAction
            XCTAssertEqual(startChild.image, UIImage(systemName: "play"))
            XCTAssertEqual(startChild.title, Strings.startRecipe)
            XCTAssertEqual(startChild.attributes, UIMenuElement.Attributes.init(rawValue: 0))

            let startAction = startChild.handler
            startAction(startChild)

            //edit
            let editChild = contextMenu!.children[1] as! UIAction
            XCTAssertEqual(editChild.image, UIImage(systemName: "pencil"))
            XCTAssertEqual(editChild.title, Strings.EditButton_Edit)
            XCTAssertEqual(editChild.attributes, UIMenuElement.Attributes.init(rawValue: 0))

            editChild.handler(editChild)

            //share
            let shareChild = contextMenu?.children[2] as! UIAction
            XCTAssertEqual(shareChild.image, UIImage(systemName: "square.and.arrow.up"))
            XCTAssertEqual(shareChild.title, Strings.share)
            XCTAssertEqual(shareChild.attributes, UIMenuElement.Attributes.init(rawValue: 0))

            shareChild.handler(shareChild)

            //dupe
            let dupeChild = contextMenu?.children[3] as! UIAction
            XCTAssertEqual(dupeChild.image, UIImage(systemName: "square.on.square"))
            XCTAssertEqual(dupeChild.title, Strings.duplicate)
            XCTAssertEqual(dupeChild.attributes, .init(rawValue: 0))

            dupeChild.handler(dupeChild)

            //favorite
            let favChild = contextMenu?.children[4] as! UIAction
            XCTAssertEqual(favChild.image, UIImage(systemName: "star"))
            XCTAssertEqual(favChild.title, Strings.addFavorite)
            XCTAssertEqual(favChild.attributes, .init(rawValue: 0))

            favChild.handler(favChild)

            //delete
            let deleteChild = contextMenu?.children.last! as! UIAction
            XCTAssertEqual(deleteChild.image, UIImage(systemName: "trash"))
            XCTAssertEqual(deleteChild.title, Strings.Alert_ActionDelete)
            XCTAssertEqual(deleteChild.attributes, .destructive)

            deleteChild.handler(deleteChild)

            secondexpectation.fulfill()
        }
        waitForExpectations(timeout: 10)
    }

}
