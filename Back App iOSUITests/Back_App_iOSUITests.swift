// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import XCTest

var app: XCUIApplication {
    XCUIApplication()
}

var appTables: XCUIElementQuery {
    app.tables
}

var navigationBar: XCUIElement {
    app.navigationBars.firstMatch
}

var addButton: XCUIElement {
    navigationBar.buttons["Add recipe"].firstMatch
}

var nameTextField: XCUIElement {
    appTables.textFields["name"]
}

var doneButton: XCUIElement {
    navigationBar.buttons["Done"]
}

var toolbar: XCUIElement {
    app.toolbars.firstMatch
}

class Back_App_iOSUITests: XCTestCase {
    

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }


    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        print("error")
    }
    
    
    func testAddingRecipeStepUpdateBug() {
        let argumentApp = app
        argumentApp.launchArguments.append("-reset")
        argumentApp.launch()
        
        addButton.tap()
        
        nameTextField.tap()
        nameTextField.typeText("testRezept")
        doneButton.tap()
        
        appTables.staticTexts["add Step"].tap()
        
        nameTextField.tap()
        nameTextField.typeText("testSchritt")
        doneButton.tap()
        
        app.navigationBars.firstMatch.buttons.firstMatch.tap()
        
        app.navigationBars.firstMatch.buttons["Cancel"].tap()
        
        app.alerts["Cancel"].scrollViews.otherElements.buttons["Delete"].tap()
    }
    
    func testAddingIngredientBug() throws {
        let argumentApp = app
        argumentApp.launchArguments.append("-reset")
        argumentApp.launch()
        
        addButton.tap()
        
        appTables.staticTexts["add Step"].tap()
        
        appTables.staticTexts["add Ingredient"].tap()
        sleep(1)
        nameTextField.tap()
        nameTextField.typeText("test")
        
        appTables.staticTexts["other"].tap()
        
        appTables.staticTexts["bulk liquid"].tap()
        
        app.navigationBars.firstMatch.buttons.firstMatch.tap()
        
        app.navigationBars.firstMatch.buttons.firstMatch.tap()
        XCUIApplication().navigationBars["unnamed recipe"].buttons["Cancel"].tap()

        app.alerts["Cancel"].scrollViews.otherElements.buttons["Delete"].tap()
        
    }
    
    func testIngredientMassTextConvertBug() {
        let argumentApp = app
        argumentApp.launchArguments.append("-reset")
        argumentApp.launch()
        
        addButton.tap()
        
        appTables.staticTexts["add Step"].tap()
        
        appTables.staticTexts["add Ingredient"].tap()
        
        nameTextField.tap()
        nameTextField.typeText("test")
        
        doneButton.tap()
        
        let amountTextField = appTables.textFields["amount in gramms"]
        amountTextField.tap()
        amountTextField.typeText("10,5")
        
        doneButton.tap()
        
        XCTAssert(appTables.textFields["10.5 g"].firstMatch.exists)
        
        app.navigationBars.firstMatch.buttons.firstMatch.tap()
                
        XCTAssert(appTables.staticTexts["10.5 g "].firstMatch.exists)
        
    }
    

    //tests adding an example recipe
    func testAddingExampleRecipe() throws {
        
        let recipe = Recipe.example
        
        let argumentApp = app
        argumentApp.launchArguments.append("-reset")
        argumentApp.launch()
        
        addButton.tap()
        
        // name
        nameTextField.tap()
        nameTextField.typeText(recipe.name)
        doneButton.tap()
        
        // quantity
        let textField = appTables.textFields["Number of breads, rolls, etc."]
        textField.tap()
        textField.typeText(recipe.timesText)
        doneButton.tap()
        
        // steps
        for step in recipe.steps {
            try addStep(step: step, recipeName: recipe.formattedName)
        }

        app.navigationBars[recipe.name].buttons["Save"].tap()
        
        XCTAssertTrue(appTables.staticTexts[recipe.name].exists)
        
        app.terminate()

        app.launch()
        app.swipeDown()
        
        XCTAssertTrue(appTables.staticTexts[recipe.name].exists)
    }
    
    func addIngredient(ingredient: Ingredient, stepName: String) {
        appTables.staticTexts["add Ingredient"].tap()
        
        // name
        nameTextField.tap()
        nameTextField.typeText(ingredient.name)
        doneButton.tap()
        
        // amount
        let amountTextField = appTables.textFields["amount in gramms"]
        amountTextField.tap()
        amountTextField.typeText("\(ingredient.amount)")
        doneButton.tap()
        
        
        
        appTables.staticTexts["other"].tap()
        
        XCTAssert(appTables.textFields[ingredient.name].exists)
        
        switch ingredient.type {
        case .bulkLiquid:
            appTables.staticTexts["bulk liquid"].tap()

        case .flour:
            appTables.staticTexts["flour"].tap()
        case .ta150:
            appTables.staticTexts["starter 50% hydration"].tap()
        case .ta200:
            appTables.staticTexts["starter 100% hydration"].tap()
        case .other:
            appTables.staticTexts["other"].firstMatch.tap()
        }
        
        XCUIApplication().navigationBars[ingredient.name].buttons[stepName].tap()
        
        XCTAssertTrue(appTables.staticTexts[ingredient.name].exists)
        
    }
    
    func addStep(step: Step, recipeName: String) throws {
        appTables.staticTexts["add Step"].tap()

        // name
        nameTextField.tap()
        nameTextField.typeText(step.name)
        doneButton.tap()

        // notes
        let notesField = appTables.textViews.firstMatch

        notesField.tap()
        notesField.typeText(step.notes)
        
        let doneButton = app.navigationBars.firstMatch.buttons["Done"]
        doneButton.tap()

        // duration
        XCUIApplication().tables.staticTexts["one minute"].firstMatch.tap()
        if step.time != 60 {
            XCUIApplication().tables.pickerWheels["one minute"].adjust(toPickerWheelValue: "\(Int(step.time/60)) minutes")
        }

        // ingredients
        for ingredient in step.ingredients {
            addIngredient(ingredient: ingredient, stepName: step.formattedName)
        }
        
        for substep in step.subSteps {
            appTables.staticTexts["add Ingredient"].tap()
            sleep(5)
            app.scrollViews.otherElements.buttons["step"].tap()
            sleep(5)
            app.scrollViews.otherElements.buttons[substep.formattedName].tap()
            
            appTables.cells.staticTexts[substep.name].firstMatch.tap()
            
            
            navigationBar.buttons[step.name].tap()
            //TODO test the tapping all the substeps
        }

        app.navigationBars[step.formattedName].buttons.firstMatch.tap()

        XCTAssertTrue(appTables.staticTexts[step.name].exists)
    }
    
    func testChangingRecipeExample() throws {
        let argumentApp = app
        argumentApp.launchArguments.append("-reset")
        argumentApp.launchArguments.append("-includeTestingRecipe")
        argumentApp.launch()

        appTables.staticTexts[Recipe.example.name].tap()
        toolbar.buttons["Edit"].tap()

        appTables.staticTexts["add Step"].tap()
        app.navigationBars["unnamed Step"].buttons[Recipe.example.name].tap()
        app.navigationBars[Recipe.example.name].buttons[Recipe.example.name].tap()

        app.navigationBars[Recipe.example.name].buttons["Recipes"].tap()

        sleep(1)
        XCTAssertTrue(appTables.staticTexts["3 steps"].exists)
    }
    
    func testInEditingDissmissCrash() throws {
        app.launch()
        app.swipeDown()
        
        addButton.tap()
        nameTextField.tap()
        app.navigationBars.firstMatch.buttons["Cancel"].tap()
    }
    
    func setupScheduleTesting() {
        let argumentApp = app
        argumentApp.launchArguments.append("-reset")
        argumentApp.launchArguments.append("-includeTestingRecipe")
        argumentApp.launch()
        
        appTables.staticTexts[Recipe.example.name].tap()
        app.tables.staticTexts["Start"].tap()
    }

    func testnormalSchedule() throws {
        // noninverted current date original Times
        setupScheduleTesting()
        doneButton.tap()
        navigationBar.buttons["OK"].tap()
        XCTAssert(appTables.staticTexts[dateFormatter.string(from: Date())].exists)
        XCTAssert(appTables.staticTexts[dateFormatter.string(from: Date().addingTimeInterval(Recipe.example.steps.first!.time))].exists)
    }
    
    func testScheduleInverted() throws {
        // inverted currentDate originalTimes
        setupScheduleTesting()
        
        let startDate = Date().addingTimeInterval(TimeInterval(-(Recipe.example.totalTime * 60)))
        let backenDate = startDate.addingTimeInterval(Recipe.example.steps.first!.time)
        
        doneButton.tap()
        appTables.segmentedControls.buttons["end"].tap()
        navigationBar.buttons["OK"].tap()
        
        XCTAssert(appTables.staticTexts[dateFormatter.string(from: startDate)].exists)
        XCTAssert(appTables.staticTexts[dateFormatter.string(from: backenDate)].exists)
    }
    
    //needs to run with en_us locale
    func testScheduleDiffrentDate() throws {
        
        // inverted diffrentDate originalTimes
        setupScheduleTesting()
        doneButton.tap()

        let newDate = Date().addingTimeInterval(3600*24*10)
        let newDateFormatter = DateFormatter()
        newDateFormatter.dateFormat = "MMM d"
        let newDateString = newDateFormatter.string(from: newDate)

        let daysSinceNewDate = (Date().timeIntervalSince(newDate)/(3600*24)).rounded()
        
        
        let picker = appTables.pickers.pickerWheels["Today"]
            
        picker.adjust(toPickerWheelValue: newDateString)
        appTables.segmentedControls.buttons["end"].tap()
        navigationBar.buttons["OK"].tap()
        
        let startDate = Date().addingTimeInterval(-(daysSinceNewDate * 3600 * 24))
            .addingTimeInterval(TimeInterval(-(Recipe.example.totalTime * 60)))
        let backenDate = startDate.addingTimeInterval(Recipe.example.steps.first!.time)
        XCTAssert(appTables.staticTexts[dateFormatter.string(from: startDate)].exists)
        XCTAssert(appTables.staticTexts[dateFormatter.string(from: backenDate)].exists)
    }
    
    func testScheduleDiffrentTimes() throws {
        //normal current Date diffrentTimes
        setupScheduleTesting()
        
        let quantityTextField = appTables.textFields["Number of breads, rolls, etc."]
        quantityTextField.tap()
        quantityTextField.typeText("10")
        doneButton.tap()
        navigationBar.buttons["OK"].tap()
        XCTAssert(appTables.staticTexts[dateFormatter.string(from: Date())].exists)
        XCTAssert(appTables.staticTexts[dateFormatter.string(from: Date().addingTimeInterval(Recipe.example.steps.first!.time))].exists)
        XCTAssert(appTables.staticTexts["1200.0 g"].exists)
        
        
    }
    
    
}
