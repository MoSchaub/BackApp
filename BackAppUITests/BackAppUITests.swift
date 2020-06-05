//
//  BackAppUITests.swift
//  BackAppUITests
//
//  Created by Moritz Schaub on 31.05.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import XCTest

class BackAppUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    
    func testAddRecipe() throws {
        
        let recipe = Recipe.example
        
        let app = XCUIApplication.init(bundleIdentifier: "com.moritzschaub.BackAppIos")
        app.launch()

        app.navigationBars["BrotApp"].staticTexts["Rezept hinzufügen"].tap()
        let returnButton = app.keyboards.buttons["Return"]
        let elementsQuery = app.scrollViews.otherElements
        let nameEingebenTextField = elementsQuery.textFields["Name eingeben"]
        nameEingebenTextField.tap()
        nameEingebenTextField.typeText(recipe.name)
        returnButton.tap()
        
        for step in recipe.steps {
            elementsQuery.buttons["Schritt hinzufügen"].tap()
            
            let nameTextField = XCUIApplication().scrollViews.otherElements.textFields["Name"]
            nameTextField.tap()
            nameTextField.typeText(step.name)
            
            
            let notesTextField = elementsQuery.textFields["Notizen..."]
            notesTextField.tap()
            notesTextField.typeText(step.notes)
            returnButton.tap()
            
            for ingredient in step.ingredients {
                let zutatHinzufügenButton = elementsQuery.buttons["Zutat hinzufügen"]
                zutatHinzufügenButton.tap()
                nameTextField.tap()
                nameTextField.typeText(ingredient.name)
                let amountTextField = elementsQuery.textFields["0.00 g"]
                amountTextField.tap()
                amountTextField.typeText("\(ingredient.amount)")
                returnButton.tap()
                if ingredient.isBulkLiquid {
                    elementsQuery.switches["Schüttflüssigkeit"].tap()
                }
                app.navigationBars[ingredient.name].buttons["OK"].tap()
                
            }
            
                        elementsQuery.buttons["Dauer:\n1 Minute"].tap()
            let picker = app.datePickers.pickers.pickerWheels["1 min"]
            
            picker.adjust(toPickerWheelValue: "\(Int(step.time))")

            app.buttons["OK"].tap()
            
            XCUIApplication().navigationBars[step.name].buttons["Speichern"].tap()
            
            XCUIApplication().children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element(boundBy: 0).swipeUp()
        }
        app.navigationBars[recipe.name].buttons["OK"].tap()
        
        app.scrollViews.otherElements.buttons["Alle ansehen"].tap()
        
        XCTAssertTrue(app.tables.cells.buttons[recipe.name].exists)
        
    }
    
    func testDeleteRecipe() throws {
        let recipe = Recipe.example
        
        let app = XCUIApplication.init(bundleIdentifier: "com.moritzschaub.BackAppIos")
        app.launch()
        
        app.scrollViews.otherElements.buttons["Alle ansehen"].tap()
        let tablesQuery = app.tables
        let testButton = tablesQuery.cells.buttons[recipe.name]
        testButton.swipeLeft()
        let deleteButton = app.tables.buttons["trailing0"]
        deleteButton.tap()
        
        XCTAssertFalse(app.tables.cells.buttons[recipe.name].exists)
    }

//    func testLaunchPerformance() throws {
//        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
//            // This measures how long it takes to launch your application.
//            measure(metrics: [XCTOSSignpostMetric.applicationLaunch]) {
//                XCUIApplication().launch()
//            }
//        }
//    }
}
