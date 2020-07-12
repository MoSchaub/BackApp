//
//  Back_App_iOSUITests.swift
//  Back App iOSUITests
//
//  Created by Moritz Schaub on 26.06.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import XCTest

class Back_App_iOSUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAddingRecipe() throws {
        
        let recipe = Recipe.example
        
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        let returnButton = app.buttons["Return"]
        let tablesQuery = app.tables
        
        app.launch()
        app.navigationBars["Baking App"].buttons["Add"].tap()
        
        // name
        app.tables.textFields["name"].tap()
        app.tables.textFields["name"].typeText(recipe.name)
        app.keyboards.buttons["Return"].tap()
        
        // quantity
        tablesQuery.staticTexts["quantity"].swipeUp()
        let textField = tablesQuery.textFields["1 piece"]
        textField.tap()
        let moreKey = app.keyboards.keys["numbers"]
        moreKey.tap()
        let key2 = app.keys["2"]
        key2.tap()
        let key0 = app.keys["0"]
        key0.tap()
        returnButton.tap()
        
        // steps
        for step in recipe.steps {
            tablesQuery.staticTexts["add Step"].tap()
            
            // name
            let nameTextField = tablesQuery.textFields["name"]
            nameTextField.tap()
            nameTextField.typeText(step.name)
            returnButton.tap()
            
            // notes
            let notesField = tablesQuery.textFields["notes"]
            notesField.tap()
            notesField.typeText(step.notes)
            returnButton.tap()
            
            // duration
            tablesQuery.cells.staticTexts["1 Minute"].tap()
            tablesQuery.cells.pickerWheels["1 min"].adjust(toPickerWheelValue: "\(Int(step.time))")
            app.navigationBars["duration"].buttons[step.name].tap()
            
            // ingredients
            for ingredient in step.ingredients {
                tablesQuery.staticTexts["add Ingredient"].tap()
                
                // name
                nameTextField.tap()
                nameTextField.typeText(ingredient.name)
                returnButton.tap()
                
                // amount
                let amountTextField = tablesQuery.textFields["0.0 g"]
                amountTextField.tap()
                moreKey.tap()
                let str = "\(ingredient.amount)"
                for char in str {
                    let key = app.keys["\(char)"]
                    key.tap()
                }
                returnButton.tap()
                
                // bulk liquid
                if ingredient.isBulkLiquid {
                    let toggle = tablesQuery.switches.firstMatch
                    toggle.tap()
                }
                XCUIApplication().navigationBars[ingredient.name].buttons["Save"].tap()
                
                XCTAssertTrue(tablesQuery.staticTexts[ingredient.name].exists)
                
            }
            
            app.navigationBars[step.name].buttons["Save"].tap()
            
            XCTAssertTrue(tablesQuery.staticTexts[step.name].exists)
        }
        
        app.navigationBars[recipe.name].buttons["Save"].tap()
        
        XCTAssertTrue(tablesQuery.staticTexts[recipe.name].exists)
    }
    
    func testCancelling() throws {
        let app = XCUIApplication()
        let tables = app.tables
        
        app.launch()
        
        app.navigationBars["Baking App"].buttons["Add"].tap()
        
        tables.cells.textFields["name"].tap()
        tables.textFields["name"].typeText("test")
        app.keyboards.buttons["Return"].tap()
        
        app.navigationBars["test"].buttons["Cancel"].tap()
        
        XCTAssertFalse(tables.staticTexts["test"].exists)
        
        //relaunch
        app.terminate()
        app.launch()
        
        XCTAssertFalse(tables.staticTexts["test"].exists)
    }
    
    func testAdding() throws {
        let app = XCUIApplication()
        let tables = app.tables
        
        app.launch()
        
        app.navigationBars["Baking App"].buttons["Add"].tap()
        
        tables.cells.textFields["name"].tap()
        tables.textFields["name"].typeText("test")
        app.keyboards.buttons["Return"].tap()
        
        app.navigationBars["test"].buttons["Save"].tap()
        
        XCTAssertTrue(tables.staticTexts["test"].exists)
        
        //relaunch
        app.terminate()
        app.launch()
        
        XCTAssertTrue(tables.staticTexts["test"].exists)
        XCTAssertTrue(tables.staticTexts[Recipe.example.name].exists)
    }
    
    func testRecipeDetail() throws {
        var app: XCUIApplication {
            XCUIApplication()
        }
        app.launch()
        
        var tablesQuery: XCUIElementQuery {
            app.tables
        }
    
        
        tablesQuery.staticTexts[Recipe.example.name].tap()

        let nameTextField = tablesQuery.textFields[Recipe.example.name]
        nameTextField.tap()
        nameTextField.typeText("TEST")
        app.keyboards.buttons["Return"].tap()

        app.navigationBars[Recipe.example.name + "TEST"].buttons["Baking App"].tap()
        
        app.terminate()
        app.launch()
        
        XCTAssertTrue(tablesQuery.staticTexts[Recipe.example.name + "TEST"].exists)
        
        
        tablesQuery.staticTexts[Recipe.example.name + "TEST"].tap()
        let nameTextField2 = tablesQuery.textFields[Recipe.example.name + "TEST"]
        nameTextField2.tap()
        
        let deleteKey = app.keys["delete"]
        deleteKey.tap()
        deleteKey.tap()
        deleteKey.tap()
        deleteKey.tap()
        app.buttons["Return"].tap()
        app.navigationBars[Recipe.example.name].buttons["Baking App"].tap()

        app.terminate()
        app.launch()
        
        XCTAssertTrue(tablesQuery.staticTexts[Recipe.example.name].exists)
    }
    
    func testChangingRoomTemp() throws {
        let app = XCUIApplication()
        app.launch()

        let tablesQuery = app.tables
        tablesQuery.cells.staticTexts["room temperature: 20ºC"].tap()
        tablesQuery.pickerWheels.firstMatch.adjust(toPickerWheelValue: "30")
        app.navigationBars["room temperature"].buttons["Baking App"].tap()
        

        XCTAssertTrue(XCUIApplication().tables.staticTexts["room temperature: 30ºC"].exists)
    }
    
    func testInfoButton() throws {
        let app = XCUIApplication()
        app.launch()

        app.tables.containing(.other, identifier:"RECIPES").element.swipeUp()
        app.tables/*@START_MENU_TOKEN@*/.staticTexts["about Baking App"]/*[[".cells.staticTexts[\"about Baking App\"]",".staticTexts[\"about Baking App\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
                        
                
    }
    
    func testModifiingStep() throws {
        let app = XCUIApplication()
        app.launch()
        
        var tablesQuery: XCUIElementQuery {
            app.tables
        }
        
        tablesQuery.staticTexts[Recipe.example.name].tap()
        
        app.tables.containing(.other, identifier:"NAME").element.swipeUp()
        
        let staticText = tablesQuery.cells.staticTexts["2 Minuten"]
        staticText.tap()
        staticText.tap()
    
        tablesQuery.cells.pickerWheels["2 min"].adjust(toPickerWheelValue: "\(18)")
        
        app.navigationBars["duration"].buttons["Mischen"].tap()
        
        app.navigationBars["Mischen"].buttons[Recipe.example.name].tap()
        
        XCTAssertTrue(tablesQuery.cells.staticTexts["18 Minuten"].exists)

        app.navigationBars[Recipe.example.name].buttons["Baking App"].tap()
        XCTAssertTrue(tablesQuery.staticTexts["36 Minuten"].exists)
    }

    
    func testDeletingRecipe() throws {
        let app = XCUIApplication()
        app.launch()
        
        let appTables = app.tables
        
        appTables.staticTexts[Recipe.example.name].swipeLeft()
        appTables.buttons["Delete"].tap()
        
        XCTAssertFalse(appTables.children(matching: .cell).element(boundBy: 0).staticTexts[Recipe.example.name].exists)
    }
}
