//
//  CompactHomeTests.swift
//  Back App iOSUITests
//
//  Created by Moritz Schaub on 25.10.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import XCTest

class CompactHomeTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    func testChangingRoomTempature() throws {
        app.launch()
        
        appTables.cells.staticTexts["room temperature"].tap()
        appTables.pickerWheels.firstMatch.adjust(toPickerWheelValue: "30")
        app.navigationBars["room temperature"].buttons["Baking App"].tap()

        XCTAssertTrue(XCUIApplication().tables.staticTexts["30° C"].exists)
    }
    
    func testNavigatingToAboutScreen() throws {
        app.launch()

        app.tables.staticTexts["about Baking App"].tap()
                        
    }
    
    func testDeletingRecipe() throws {
        app.launch()
        try! delete(recipe: Recipe.example)
    }
    
    func delete(recipe: Recipe) throws {
        appTables.staticTexts[recipe.name].swipeLeft()
        appTables.buttons["Delete"].tap()
        XCTAssertFalse(appTables.children(matching: .cell).element(boundBy: 0).staticTexts[recipe.name].exists)
    }

}
