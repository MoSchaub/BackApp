// SPDX-FileCopyrightText: 2026 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import XCTest
import BakingRecipeStrings

/// Shared setup, elements and helpers for the UI tests.
///
/// Every test gets a fresh `app` that starts with an empty database (`-reset`),
/// without animations, in English and with Celsius. Controls are found by their
/// `AccessibilityID`; only content checks (recipe names, amounts) match on text.
/// Add launch arguments in the test before calling `app.launch()`.
class BackAppUITestCase: XCTestCase {

    /// How long to wait for an element before failing.
    let timeout: TimeInterval = 5

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false

        app = XCUIApplication()
        app.launchArguments = [
            "-reset",
            "-disableAnimations",
            "-AppleLanguages", "(en)",
            // en_GB: English labels, °C and "." as decimal separator
            "-AppleLocale", "en_GB",
        ]
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Elements

    var navigationBar: XCUIElement { app.navigationBars.firstMatch }
    /// The system back button of the current screen
    var backButton: XCUIElement { navigationBar.buttons.firstMatch }
    var addButton: XCUIElement { app.buttons[AccessibilityID.addRecipeButton].firstMatch }
    var settingsButton: XCUIElement { app.buttons[AccessibilityID.settingsButton].firstMatch }
    var nameTextField: XCUIElement { app.textFields[AccessibilityID.nameField] }
    var doneButton: XCUIElement { app.buttons[AccessibilityID.doneButton].firstMatch }

    /// The table cell with accessibility identifier `id`
    func cell(_ id: String) -> XCUIElement { app.cells[id].firstMatch }

    // MARK: - Helpers

    /// Fails the test if `element` doesn't appear within `timeout`.
    ///
    /// Checks `exists` first: `waitForExistence` costs over a second even when
    /// the element is already there, which adds up in the longer flows.
    func assertExists(_ element: XCUIElement, file: StaticString = #filePath, line: UInt = #line) {
        guard !element.exists else { return }
        XCTAssertTrue(element.waitForExistence(timeout: timeout), "\(element) did not appear", file: file, line: line)
    }

    /// Fails the test if the text field's value isn't `expected`.
    func assertValue(of element: XCUIElement, is expected: String, file: StaticString = #filePath, line: UInt = #line) {
        assertExists(element, file: file, line: line)
        XCTAssertEqual(element.value as? String, expected, file: file, line: line)
    }

    /// Taps `element` and types `text` into it.
    /// Waits for the field because it can still be reloading after the previous edit.
    func type(_ text: String, into element: XCUIElement, file: StaticString = #filePath, line: UInt = #line) {
        assertExists(element, file: file, line: line)
        element.tap()
        element.typeText(text)
    }
}
