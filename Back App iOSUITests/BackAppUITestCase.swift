// SPDX-FileCopyrightText: 2026 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import XCTest

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
        applyRequestedOrientation()

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
    /// The system back button of the current screen.
    ///
    /// In the split view the back button of the detail column isn't the first button of the first
    /// navigation bar (that's the sidebar's), and on the iPhone Duo it isn't inside a navigation bar at all,
    /// so look it up by the system identifier there.
    var backButton: XCUIElement {
        isSplitView ? app.buttons[AccessibilityID.systemBackButton].firstMatch : navigationBar.buttons.firstMatch
    }
    var addButton: XCUIElement { app.buttons[AccessibilityID.addRecipeButton].firstMatch }
    var settingsButton: XCUIElement { app.buttons[AccessibilityID.settingsButton].firstMatch }
    var nameTextField: XCUIElement { app.textFields[AccessibilityID.nameField] }
    var doneButton: XCUIElement { app.buttons[AccessibilityID.doneButton].firstMatch }

    /// The table cell with accessibility identifier `id`
    func cell(_ id: String) -> XCUIElement { app.cells[id].firstMatch }

    /// Whether the app shows the recipe list as a sidebar next to the detail (iPad, unfolded iPhone Duo)
    /// instead of a single navigation stack (iPhone).
    var isSplitView: Bool { app.windows.firstMatch.horizontalSizeClass == .regular }

    // MARK: - Helpers

    /// Opens the settings from the recipe list.
    /// In the sidebar the settings are an action in the navigation bar's overflow menu (⋯), on the iPhone a button.
    func openSettings(file: StaticString = #filePath, line: UInt = #line) {
        guard isSplitView else {
            settingsButton.tap()
            return
        }
        // the system overflow button has no identifier, only its label
        let overflowButton = app.navigationBars.buttons["More"].firstMatch
        guard overflowButton.waitForExistence(timeout: timeout) else {
            XCTFail("overflow menu button not found in\n\(app.debugDescription)", file: file, line: line)
            return
        }
        overflowButton.tap()

        let settingsAction = app.buttons.matching(
            NSPredicate(format: "identifier == %@ OR label == %@", AccessibilityID.settingsButton, "Settings")).firstMatch
        assertExists(settingsAction, file: file, line: line)
        settingsAction.tap()
    }

    /// Goes back from the recipe detail to the recipe list.
    /// In the split view the list is always visible next to the detail, so there's nothing to do.
    func backToRecipeList(file: StaticString = #filePath, line: UInt = #line) {
        guard !isSplitView else { return }
        backButton.tap()
        assertExists(addButton, file: file, line: line)
    }

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

/// Rotates the device if the test run asks for it with `UI_TEST_ORIENTATION=portrait` or `landscape`,
/// e.g. `TEST_RUNNER_UI_TEST_ORIENTATION=portrait xcodebuild test …` to run the UI tests on an iPad in portrait.
func applyRequestedOrientation() {
    switch ProcessInfo.processInfo.environment["UI_TEST_ORIENTATION"] {
    case "portrait": XCUIDevice.shared.orientation = .portrait
    case "landscape": XCUIDevice.shared.orientation = .landscapeLeft
    default: break
    }
}
