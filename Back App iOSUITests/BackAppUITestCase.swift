// SPDX-FileCopyrightText: 2026 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import XCTest

/// Shared setup, elements and helpers for the UI tests.
///
/// Every test gets a fresh `app` that starts with an empty database (`-reset`),
/// in English and with Celsius, since the tests match on those labels.
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
            "-AppleLanguages", "(en)",
            // en_GB: English labels, °C and "." as decimal separator
            "-AppleLocale", "en_GB",
        ]
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Elements

    var appTables: XCUIElementQuery { app.tables }
    var navigationBar: XCUIElement { app.navigationBars.firstMatch }
    var backButton: XCUIElement { navigationBar.buttons.firstMatch }
    var addButton: XCUIElement { navigationBar.buttons["Add recipe"].firstMatch }
    var settingsButton: XCUIElement { navigationBar.buttons["settings"] }
    var nameTextField: XCUIElement { appTables.textFields["name"] }
    var doneButton: XCUIElement { navigationBar.buttons["Done"] }
    var toolbar: XCUIElement { app.toolbars.firstMatch }

    // MARK: - Helpers

    /// Fails the test if `element` doesn't appear within `timeout`.
    ///
    /// Checks `exists` first: `waitForExistence` costs over a second even when
    /// the element is already there, which adds up in the longer flows.
    func assertExists(_ element: XCUIElement, file: StaticString = #filePath, line: UInt = #line) {
        guard !element.exists else { return }
        XCTAssertTrue(element.waitForExistence(timeout: timeout), "\(element) did not appear", file: file, line: line)
    }

    /// Taps `element` and types `text` into it.
    /// Waits for the field because it can still be reloading after the previous edit.
    func type(_ text: String, into element: XCUIElement, file: StaticString = #filePath, line: UInt = #line) {
        assertExists(element, file: file, line: line)
        element.tap()
        element.typeText(text)
    }
}
