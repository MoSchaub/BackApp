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
    
    func testAddingSubstep() throws {
        let sub1 = Step(name: "Sub1", ingredients: [Ingredient(name: "Mehl", amount: 1000)])
        var sub2 = Step(name: "Sub2")
        sub2.subSteps.append(sub1)
        var sub3 = Step(name: "Sub3")
        sub3.subSteps.append(sub2)
        
        let subs = [sub1, sub2, sub3]
        let recipe = Recipe(name: "unnamed recipe", brotValues: subs)
        
        app.launch()
        
        addButton.tap()

        for sub in subs {
            
            let addStepButton = appTables.staticTexts["add Step"]
            let doneButton = app.toolbars["Toolbar"].buttons["Done"]
            
            addStepButton.tap()

            nameTextField.tap()
            nameTextField.typeText(sub.name)
            doneButton.tap()
            for ingredient in sub.ingredients {
                let addIngredientButton = appTables.staticTexts["add Ingredient"]
                addIngredientButton.tap()
                nameTextField.tap()
                nameTextField.typeText(ingredient.name)
                doneButton.tap()
                
                let amountTextField = appTables.textFields["amount in gramms"]
                amountTextField.tap()
                amountTextField.typeText("\(ingredient.amount)")
                doneButton.tap()
                
                app.navigationBars[ingredient.name].buttons["Save"].tap()
            }
            
            for substep in sub.subSteps {
                let addIngredientButton = appTables.staticTexts["add Ingredient"]
                addIngredientButton.tap()
                app.sheets["new ingredient or step as ingredient?"].scrollViews.otherElements.buttons["step"].tap()
                app.sheets["select Step"].scrollViews.otherElements.buttons[substep.name].tap()
            }
            
            app.navigationBars[sub.name].buttons["Save"].tap()
        }
        
        app.navigationBars["unnamed recipe"].buttons["Save"].tap()

        
    }

    func testa() throws {
        
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
        let textField = appTables.textFields["Number of breads, rolls, etc."]
        textField.tap()
        textField.typeText(recipe.timesText)
        returnButton.tap()
        
        // steps
        for step in recipe.steps {
            appTables.staticTexts["add Step"].tap()
            
            // name
            nameTextField.tap()
            nameTextField.typeText(step.name)
            returnButton.tap()
            
            // notes
            let notesField = appTables.textViews[Strings.notes]
            notesField.tap()
            notesField.typeText(step.notes)
            
            let doneButton = app.toolbars["Toolbar"].buttons["Done"]
            doneButton.tap()
            
            // duration
            appTables.cells.staticTexts["one minute"].tap()
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
                let amountTextField = appTables.textFields["amount in gramms"]
                amountTextField.tap()
                amountTextField.typeText("\(ingredient.amount)")
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
        
        app.terminate()

        app.launch()
        
        XCTAssertTrue(appTables.staticTexts[recipe.name].exists)
    }
    
    func testb() throws {
        
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
    
    func testc() throws {
        
        let recipe = Recipe(name: "test", brotValues: [])
        
        app.launch()
        
        addButton.tap()
        
        nameTextField.tap()
        nameTextField.typeText(recipe.name)
        returnButton.tap()
        
        app.navigationBars[recipe.name].buttons["Save"].tap()
        
        XCTAssertTrue(appTables.staticTexts[recipe.name].exists)
        
        //relaunch
        app.terminate()
        app.launch()
        
        XCTAssertTrue(appTables.staticTexts[recipe.name].exists)
        XCTAssertTrue(appTables.staticTexts[Recipe.example.name].exists)

        app.navigationBars["Baking App"].buttons["Edit"].tap()

        let app = XCUIApplication()
        let tablesQuery = app.tables
        tablesQuery.children(matching: .cell).element(boundBy: 2).buttons["Delete "].tap()
        tablesQuery.buttons["trailing0"].tap()
        app.navigationBars["Baking App"].buttons["Done"].tap()
    }
    
    func testd() throws {
        
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
    
    func teste() throws {
        app.launch()
        
        appTables.cells.staticTexts["room temperature"].tap()
        appTables.pickerWheels.firstMatch.adjust(toPickerWheelValue: "30")
        app.navigationBars["room temperature"].buttons["Baking App"].tap()

        XCTAssertTrue(XCUIApplication().tables.staticTexts["30° C"].exists)
    }
    
    func testf() throws {
        app.launch()

        app.tables.staticTexts["about Baking App"].tap()
                        
    }
    
    func testg() throws {

        app.launch()

        appTables.staticTexts[Recipe.example.name].tap()
        
        let staticText = appTables.cells.staticTexts["2 minutes"]
        staticText.tap()
        staticText.tap()
    
        appTables.cells.pickerWheels["2 min"].adjust(toPickerWheelValue: "\(18)")
        
        app.navigationBars["duration"].buttons["Mischen"].tap()
        
        app.navigationBars["Mischen"].buttons[Recipe.example.name].tap()
        
        XCTAssertTrue(appTables.cells.staticTexts["18 minutes"].exists)

        app.navigationBars[Recipe.example.name].buttons["Baking App"].tap()
        
        XCTAssertTrue(appTables.staticTexts["36 minutes"].exists)
    }
    
    func delete(recipe: Recipe) throws {
        appTables.staticTexts[recipe.name].swipeLeft()
        appTables.buttons["Delete"].tap()
        XCTAssertFalse(appTables.children(matching: .cell).element(boundBy: 0).staticTexts[recipe.name].exists)
    }
    
    func testh() throws {
        app.launch()
        try! delete(recipe: Recipe.example)
    }
}
