// Copyright © 2020 Moritz Schaub. All rights reserved.
// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import XCTest

final class CompactHomeTests: BackAppUITestCase {

    func testChangingRoomTempature() throws {
        app.launch()
        app.swipeDown()

        setRoomTemperature("30")
        settingsButton.tap()
        assertExists(app.staticTexts["30°C"])

        // relaunch to check the setting was persisted, then restore the default
        app.terminate()
        app.launch()
        app.swipeDown()

        setRoomTemperature("20")
        settingsButton.tap()
        assertExists(app.staticTexts["20°C"])
    }

    func testNavigatingToAboutScreen() throws {
        app.launch()
        app.swipeDown()

        settingsButton.tap()
        cell(AccessibilityID.aboutCell).tap()

        assertExists(app.navigationBars["about Baking App"])
    }

    func testDeletingRecipe() throws {
        let recipeName = Recipe.example.name
        app.launchArguments.append("-includeTestingRecipe")
        app.launch()

        let recipe = app.staticTexts[recipeName].firstMatch
        assertExists(recipe)
        recipe.swipeLeft()
        // the swipe action is a system button, so it's found by its title
        app.buttons["Delete"].tap()

        XCTAssertTrue(recipe.waitForNonExistence(timeout: timeout), "\(recipeName) was not deleted")
    }

    // MARK: - Helpers

    /// Opens the settings, picks `temperature` as room temperature and goes back to the recipe list.
    private func setRoomTemperature(_ temperature: String) {
        settingsButton.tap()
        cell(AccessibilityID.roomTemperatureCell).tap()

        let picker = app.pickerWheels.firstMatch
        assertExists(picker)
        picker.adjust(toPickerWheelValue: temperature)

        app.buttons[AccessibilityID.closeSettingsButton].tap()
    }
}
