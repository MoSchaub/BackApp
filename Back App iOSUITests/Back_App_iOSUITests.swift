//
//  Back_App_iOSUITests.swift
//  Back App iOSUITests
//
//  Created by Moritz Schaub on 26.06.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import XCTest

class Back_App_iOSUITests: XCTestCase {
    
    private var app: XCUIApplication {
        XCUIApplication()
    }
    
    private var appTables: XCUIElementQuery {
        app.tables
    }
    
    private var navigationBar: XCUIElement {
        app.navigationBars.firstMatch
    }
    
    private var addButton: XCUIElement {
        navigationBar.buttons["Add"]
    }
    
    private var nameTextField: XCUIElement {
        appTables.textFields["name"]
    }
    
    private var returnButton: XCUIElement {
        app.keyboards.buttons["Return"]
    }

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
        let returnButton = app.buttons["Return"]
        
        app.launch()
        addButton.tap()
        
        // name
        nameTextField.tap()
        nameTextField.typeText(recipe.name)
        returnButton.tap()
        
        // quantity
        appTables.staticTexts["quantity"].swipeUp()
        let textField = appTables.textFields["1 piece"]
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
            appTables.staticTexts["add Step"].tap()
            
            // name
            nameTextField.tap()
            nameTextField.typeText(step.name)
            returnButton.tap()
            
            // notes
            let notesField = appTables.textFields["notes"]
            notesField.tap()
            notesField.typeText(step.notes)
            returnButton.tap()
            
            // duration
            appTables.cells.staticTexts["1 Minute"].tap()
            appTables.cells.pickerWheels["1 min"].adjust(toPickerWheelValue: "\(Int(step.time))")
            app.navigationBars["duration"].buttons[step.name].tap()
            
            // ingredients
            for ingredient in step.ingredients {
                appTables.staticTexts["add Ingredient"].tap()
                
                // name
                nameTextField.tap()
                nameTextField.typeText(ingredient.name)
                returnButton.tap()
                
                // amount
                let amountTextField = appTables.textFields["0.0 g"]
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
                    let toggle = appTables.switches.firstMatch
                    toggle.tap()
                }
                XCUIApplication().navigationBars[ingredient.name].buttons["Save"].tap()
                
                XCTAssertTrue(appTables.staticTexts[ingredient.name].exists)
                
            }
            
            app.navigationBars[step.name].buttons["Save"].tap()
            
            XCTAssertTrue(appTables.staticTexts[step.name].exists)
        }
        
        app.navigationBars[recipe.name].buttons["Save"].tap()
        
        XCTAssertTrue(appTables.staticTexts[recipe.name].exists)
    }
    
    func testCancelling() throws {
        
        app.launch()
        
        addButton.tap()
        
        nameTextField.tap()
        nameTextField.typeText("test")
        returnButton.tap()
        
        app.navigationBars["test"].buttons["Cancel"].tap()
        
        XCTAssertFalse(appTables.staticTexts["test"].exists)
        
        //relaunch
        app.terminate()
        app.launch()
        
        XCTAssertFalse(appTables.staticTexts["test"].exists)
    }
    
    func testAdding() throws {
        
        app.launch()
        
        addButton.tap()
        
        nameTextField.tap()
        nameTextField.typeText("test")
        returnButton.tap()
        
        app.navigationBars["test"].buttons["Save"].tap()
        
        XCTAssertTrue(appTables.staticTexts["test"].exists)
        
        //relaunch
        app.terminate()
        app.launch()
        
        XCTAssertTrue(appTables.staticTexts["test"].exists)
        XCTAssertTrue(appTables.staticTexts[Recipe.example.name].exists)
    }
    
    func testRecipeDetail() throws {
        
        app.launch()

        appTables.staticTexts[Recipe.example.name].tap()

        let nameTextField = appTables.textFields[Recipe.example.name]
        nameTextField.tap()
        nameTextField.typeText("TEST")
        app.keyboards.buttons["Return"].tap()

        app.navigationBars[Recipe.example.name + "TEST"].buttons["Baking App"].tap()
        
        app.terminate()
        app.launch()
        
        XCTAssertTrue(appTables.staticTexts[Recipe.example.name + "TEST"].exists)
        
        
        appTables.staticTexts[Recipe.example.name + "TEST"].tap()
        let nameTextField2 = appTables.textFields[Recipe.example.name + "TEST"]
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
        
        XCTAssertTrue(appTables.staticTexts[Recipe.example.name].exists)
    }
    
    func testChangingRoomTemp() throws {
        app.launch()
        
        appTables.cells.staticTexts["room temperature: 20ºC"].tap()
        appTables.pickerWheels.firstMatch.adjust(toPickerWheelValue: "30")
        app.navigationBars["room temperature"].buttons["Baking App"].tap()
        

        XCTAssertTrue(XCUIApplication().tables.staticTexts["room temperature: 30ºC"].exists)
    }
    
    func testInfoButton() throws {
        app.launch()

        app.tables.containing(.other, identifier:"RECIPES").element.swipeUp()
        app.tables.staticTexts["about Baking App"].tap()
                        
    }
    
    func testModifiingStep() throws {

        app.launch()

        appTables.staticTexts[Recipe.example.name].tap()
        
        appTables.containing(.other, identifier:"NAME").element.swipeUp()
        
        let staticText = appTables.cells.staticTexts["2 Minuten"]
        staticText.tap()
        staticText.tap()
    
        appTables.cells.pickerWheels["2 min"].adjust(toPickerWheelValue: "\(18)")
        
        app.navigationBars["duration"].buttons["Mischen"].tap()
        
        app.navigationBars["Mischen"].buttons[Recipe.example.name].tap()
        
        XCTAssertTrue(appTables.cells.staticTexts["18 Minuten"].exists)

        app.navigationBars[Recipe.example.name].buttons["Baking App"].tap()
        XCTAssertTrue(appTables.staticTexts["36 Minuten"].exists)
    }

    
    func testDeletingRecipe() throws {
        app.launch()
        
        appTables.staticTexts[Recipe.example.name].swipeLeft()
        appTables.buttons["Delete"].tap()
        
        XCTAssertFalse(appTables.children(matching: .cell).element(boundBy: 0).staticTexts[Recipe.example.name].exists)
    }
}
