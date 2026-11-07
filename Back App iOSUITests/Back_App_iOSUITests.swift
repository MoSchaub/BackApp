// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import XCTest

final class Back_App_iOSUITests: BackAppUITestCase {

    private var cancelDeleteButton: XCUIElement {
        app.alerts["Cancel"].scrollViews.otherElements.buttons["Delete"]
    }

    // MARK: - Tests

    func testAddingRecipeStepUpdateBug() throws {
        app.launch()

        addButton.tap()
        type("testRezept", into: nameTextField)
        doneButton.tap()

        appTables.staticTexts["add Step"].tap()
        type("testSchritt", into: nameTextField)
        doneButton.tap()

        backButton.tap()
        navigationBar.buttons["Cancel"].tap()
        cancelDeleteButton.tap()
    }

    func testAddingIngredientBug() throws {
        app.launch()

        addButton.tap()
        appTables.staticTexts["add Step"].tap()
        appTables.staticTexts["add Ingredient"].tap()

        type("test", into: nameTextField)

        appTables.staticTexts["other"].tap()
        appTables.staticTexts["bulk liquid"].tap()

        backButton.tap()
        backButton.tap()
        app.navigationBars["unnamed recipe"].buttons["Cancel"].tap()
        cancelDeleteButton.tap()
    }

    func testIngredientMassTextConvertBug() throws {
        app.launch()

        addButton.tap()
        appTables.staticTexts["add Step"].tap()
        appTables.staticTexts["add Ingredient"].tap()

        type("test", into: nameTextField)
        doneButton.tap()

        type("10,5", into: appTables.textFields["amount in gramms"])
        doneButton.tap()

        assertExists(appTables.textFields["10.5 g"].firstMatch)

        backButton.tap()

        assertExists(appTables.staticTexts["10.5 g "].firstMatch)
    }

    /// Enters `Recipe.example` through the UI and checks it is still there after a relaunch.
    func testAddingExampleRecipe() throws {
        let recipe = Recipe.example

        app.launch()

        addButton.tap()

        // name
        type(recipe.name, into: nameTextField)
        doneButton.tap()

        // quantity
        type(recipe.timesText, into: appTables.textFields["Number of breads, rolls, etc."])
        doneButton.tap()

        // steps
        for step in recipe.steps {
            addStep(step)
        }

        app.navigationBars[recipe.name].buttons["Save"].tap()

        assertExists(appTables.staticTexts[recipe.name])

        // relaunch without resetting the database to check the recipe was persisted
        app.terminate()
        app.launchArguments.removeAll { $0 == "-reset" }
        app.launch()
        app.swipeDown()

        assertExists(appTables.staticTexts[recipe.name])
    }

    func testChangingRecipeExample() throws {
        let recipeName = Recipe.example.name
        app.launchArguments.append("-includeTestingRecipe")
        app.launch()

        appTables.staticTexts[recipeName].tap()
        toolbar.buttons["Edit"].tap()

        appTables.staticTexts["add Step"].tap()
        app.navigationBars["unnamed Step"].buttons[recipeName].tap()
        app.navigationBars[recipeName].buttons[recipeName].tap()
        app.navigationBars[recipeName].buttons["Recipes"].tap()

        assertExists(appTables.staticTexts["3 steps"])
    }

    func testInEditingDissmissCrash() throws {
        app.launch()
        app.swipeDown()

        addButton.tap()
        nameTextField.tap()
        navigationBar.buttons["Cancel"].tap()
    }

    // The schedule tests (testnormalSchedule, testScheduleInverted, testScheduleDiffrentDate,
    // testScheduleDiffrentTimes) were reworked into unit tests, since they only verified
    // date math and amount scaling: see BackAppCoreTests/ScheduleAndFormattingTests.swift.

    // MARK: - Flows

    private func addIngredient(_ ingredient: Ingredient, stepName: String) {
        appTables.staticTexts["add Ingredient"].tap()

        // name
        type(ingredient.name, into: nameTextField)
        doneButton.tap()

        // amount
        type("\(ingredient.amount)", into: appTables.textFields["amount in gramms"])
        doneButton.tap()

        appTables.staticTexts["other"].tap()

        assertExists(appTables.textFields[ingredient.name])

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

        app.navigationBars[ingredient.name].buttons[stepName].tap()

        assertExists(appTables.staticTexts[ingredient.name])
    }

    private func addStep(_ step: Step) {
        appTables.staticTexts["add Step"].tap()

        // name
        type(step.name, into: nameTextField)
        doneButton.tap()

        // notes
        type(step.notes, into: appTables.textViews.firstMatch)
        doneButton.tap()

        // duration
        appTables.staticTexts["one minute"].firstMatch.tap()
        if step.time != 60 {
            let picker = appTables.pickerWheels["one minute"]
            assertExists(picker)
            picker.adjust(toPickerWheelValue: "\(Int(step.time / 60)) minutes")
        }

        // ingredients
        for ingredient in step.ingredients {
            addIngredient(ingredient, stepName: step.formattedName)
        }

        // substeps
        for substep in step.subSteps {
            appTables.staticTexts["add Ingredient"].tap()
            app.scrollViews.otherElements.buttons["step"].tap()
            app.scrollViews.otherElements.buttons[substep.formattedName].tap()
            appTables.cells.staticTexts[substep.name].firstMatch.tap()
            navigationBar.buttons[step.name].tap()
            // TODO: test tapping all the substeps
        }

        app.navigationBars[step.formattedName].buttons.firstMatch.tap()

        assertExists(appTables.staticTexts[step.name])
    }
}
