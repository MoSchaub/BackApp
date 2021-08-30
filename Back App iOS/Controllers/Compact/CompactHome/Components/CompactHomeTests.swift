//
//  CompactHomeTests.swift
//  Back App iOSUITests
//
//  Created by Moritz Schaub on 25.10.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import XCTest

var settingsButton: XCUIElement {
    navigationBar.buttons["settings"]
}

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
        app.swipeDown()
        
        settingsButton.tap()
        
        appTables.cells.staticTexts["room temperature"].tap()
        appTables.pickerWheels.firstMatch.adjust(toPickerWheelValue: "30")
        
        app.navigationBars["Settings"].buttons["Recipes"].tap()        
        
        settingsButton.tap()
        XCTAssertTrue(XCUIApplication().tables.staticTexts["30.0° C"].exists)
        
        app.terminate()

        app.launch()
        app.swipeDown()
        
        settingsButton.tap()
        
        appTables.cells.staticTexts["room temperature"].tap()
        
        appTables.pickerWheels.firstMatch.adjust(toPickerWheelValue: "20")
        app.navigationBars["Settings"].buttons["Recipes"].tap()
        
        settingsButton.tap()
        XCTAssertTrue(XCUIApplication().tables.staticTexts["20.0° C"].exists)
    }
    
    func testNavigatingToAboutScreen() throws {
        app.launch()
        app.swipeDown()

        settingsButton.tap()
        
        appTables.cells.staticTexts["about Baking App"].tap()
        
        XCTAssert(app.navigationBars["about Baking App"].exists)
                        
    }
    
    func testDeletingRecipe() throws {
        let argumentApp = app
        argumentApp.launchArguments.append("-reset")
        argumentApp.launchArguments.append("-includeTestingRecipe")
        argumentApp.launch()
        
        try! delete(recipeName: Recipe.example.name)
    }

}

func delete(recipeName: String) throws {
    
    appTables.staticTexts[recipeName].firstMatch.swipeLeft()
    appTables.buttons["Delete"].tap()
    XCTAssertFalse(appTables.children(matching: .cell).element(boundBy: 0).staticTexts[recipeName].exists)
}


