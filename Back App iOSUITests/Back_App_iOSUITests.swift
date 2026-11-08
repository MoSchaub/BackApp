// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import XCTest

final class Back_App_iOSUITests: BackAppUITestCase {

    private var saveRecipeButton: XCUIElement { app.buttons[AccessibilityID.saveRecipeButton].firstMatch }
    private var cancelRecipeButton: XCUIElement { app.buttons[AccessibilityID.cancelRecipeButton].firstMatch }
    private var addStepCell: XCUIElement { cell(AccessibilityID.addStepCell) }
    private var addIngredientCell: XCUIElement { cell(AccessibilityID.addIngredientCell) }
    private var amountTextField: XCUIElement { app.textFields[AccessibilityID.ingredientAmountField] }

    /// "Delete" in the alert shown when cancelling a new recipe.
    /// Alert actions can't have an accessibility identifier, so this one is found by its title.
    private var cancelDeleteButton: XCUIElement {
        app.alerts[AccessibilityID.cancelRecipeAlert].buttons["Delete"]
    }

    // MARK: - Tests

    func testAddingRecipeStepUpdateBug() throws {
        app.launch()

        addButton.tap()
        type("testRezept", into: nameTextField)
        doneButton.tap()

        addStepCell.tap()
        type("testSchritt", into: nameTextField)
        doneButton.tap()

        backButton.tap()
        cancelRecipeButton.tap()
        cancelDeleteButton.tap()
    }

    func testAddingIngredientBug() throws {
        app.launch()

        addButton.tap()
        addStepCell.tap()
        addIngredientCell.tap()

        type("test", into: nameTextField)

        cell(AccessibilityID.ingredientTypeCell).tap()
        cell(AccessibilityID.ingredientTypeOption("bulkLiquid")).tap()

        backButton.tap()
        backButton.tap()
        cancelRecipeButton.tap()
        cancelDeleteButton.tap()
    }

    func testIngredientMassTextConvertBug() throws {
        app.launch()

        addButton.tap()
        addStepCell.tap()
        addIngredientCell.tap()

        type("test", into: nameTextField)
        doneButton.tap()

        type("10,5", into: amountTextField)
        doneButton.tap()

        assertValue(of: amountTextField, is: "10.5 g")

        backButton.tap()

        assertExists(app.staticTexts["10.5 g "].firstMatch)
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
        type(recipe.timesText, into: app.textFields[AccessibilityID.recipeQuantityField])
        doneButton.tap()

        // steps
        for step in recipe.steps {
            addStep(step)
        }

        saveRecipeButton.tap()

        assertExists(app.staticTexts[recipe.name])

        // relaunch without resetting the database to check the recipe was persisted
        app.terminate()
        app.launchArguments.removeAll { $0 == "-reset" }
        app.launch()
        app.swipeDown()

        assertExists(app.staticTexts[recipe.name])
    }

    func testChangingRecipeExample() throws {
        app.launchArguments.append("-includeTestingRecipe")
        app.launch()

        app.staticTexts[Recipe.example.name].tap()
        app.buttons[AccessibilityID.editRecipeButton].firstMatch.tap()

        addStepCell.tap()
        backButton.tap() // step -> edit recipe
        backButton.tap() // edit recipe -> recipe detail
        backButton.tap() // recipe detail -> recipe list

        assertExists(app.staticTexts["3 steps"])
    }

    /// After iOS terminated the app in the background, it reopens the recipe that was shown (#29).
    func testShownRecipeIsRestoredAfterTerminationInBackground() throws {
        app.launchArguments.append("-includeTestingRecipe")
        app.launch()

        app.staticTexts[Recipe.example.name].tap()
        assertExists(app.buttons[AccessibilityID.editRecipeButton])

        relaunchAfterTerminationInBackground()

        assertExists(app.buttons[AccessibilityID.editRecipeButton])
        XCTAssertTrue(app.navigationBars[Recipe.example.name].exists)
    }

    /// After going back to the list, a relaunch starts on the list again (#29).
    func testRecipeListIsRestoredAfterLeavingRecipe() throws {
        app.launchArguments.append("-includeTestingRecipe")
        app.launch()

        app.staticTexts[Recipe.example.name].tap()
        assertExists(app.buttons[AccessibilityID.editRecipeButton])
        backButton.tap()
        assertExists(addButton)

        relaunchAfterTerminationInBackground()

        assertExists(addButton)
        XCTAssertFalse(app.buttons[AccessibilityID.editRecipeButton].exists)
    }

    func testInEditingDissmissCrash() throws {
        app.launch()
        app.swipeDown()

        addButton.tap()
        nameTextField.tap()
        cancelRecipeButton.tap()
    }

    // The schedule tests (testnormalSchedule, testScheduleInverted, testScheduleDiffrentDate,
    // testScheduleDiffrentTimes) were reworked into unit tests, since they only verified
    // date math and amount scaling: see BackAppCoreTests/ScheduleAndFormattingTests.swift.

    // MARK: - Flows

    /// Sends the app to the background, kills it like iOS does to free memory and launches it again
    /// with the same database. Unlike swiping it away in the app switcher, this keeps the scene's
    /// state restoration activity.
    private func relaunchAfterTerminationInBackground() {
        XCUIDevice.shared.press(.home)
        XCTAssertTrue(app.wait(for: .runningBackgroundSuspended, timeout: timeout)
                      || app.state == .runningBackground)

        app.terminate()
        app.launchArguments.removeAll { $0 == "-reset" || $0 == "-includeTestingRecipe" }
        app.launch()
    }

    private func addIngredient(_ ingredient: Ingredient) {
        addIngredientCell.tap()

        // name
        type(ingredient.name, into: nameTextField)
        doneButton.tap()

        // amount
        type("\(ingredient.amount)", into: amountTextField)
        doneButton.tap()

        assertValue(of: nameTextField, is: ingredient.name)

        // type
        cell(AccessibilityID.ingredientTypeCell).tap()
        cell(AccessibilityID.ingredientTypeOption("\(ingredient.type)")).tap()

        backButton.tap()

        assertExists(app.staticTexts[ingredient.name])
    }

    private func addStep(_ step: Step) {
        addStepCell.tap()

        // name
        type(step.name, into: nameTextField)
        doneButton.tap()

        // notes
        type(step.notes, into: app.textViews.firstMatch)
        doneButton.tap()

        // duration
        cell(AccessibilityID.stepDurationCell).tap()
        if step.time != 60 {
            // the second wheel holds the minutes
            let minutesWheel = app.pickers[AccessibilityID.stepDurationPicker].pickerWheels.element(boundBy: 1)
            assertExists(minutesWheel)
            minutesWheel.adjust(toPickerWheelValue: "\(Int(step.time / 60)) minutes")
        }

        // ingredients
        for ingredient in step.ingredients {
            addIngredient(ingredient)
        }

        // substeps (Recipe.example has none, so this isn't run at the moment)
        for substep in step.subSteps {
            addIngredientCell.tap()
            app.scrollViews.otherElements.buttons["step"].tap()
            app.scrollViews.otherElements.buttons[substep.formattedName].tap()
            app.cells.staticTexts[substep.name].firstMatch.tap()
            backButton.tap()
            // TODO: test tapping all the substeps
        }

        backButton.tap()

        assertExists(app.staticTexts[step.name])
    }
}
