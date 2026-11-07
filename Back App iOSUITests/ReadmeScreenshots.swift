// SPDX-FileCopyrightText: 2026 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import XCTest

/// Takes the screenshots used in the README.
///
/// The app is launched with `-screenshotMode`, which replaces the database with the
/// example recipes bundled with the app, so the screenshots always show the same data.
///
/// Run it with `scripts/screenshots/take_screenshots.sh`, which sets the simulator status bar,
/// passes `SCREENSHOT_DIR` to this test and frames the results.
/// The screenshots are also attached to the test result.
final class ReadmeScreenshots: XCTestCase {

    private let recipeName = "Simple cut rolls"
    private let stepName = "Main dough"
    private let ingredientName = "Wheat bread flour"

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false

        app = XCUIApplication()
        app.launchArguments += ["-screenshotMode", "-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch()
    }

    func testTakeReadmeScreenshots() throws {
        // 1. recipe list
        let recipeCell = app.staticTexts[recipeName].firstMatch
        XCTAssertTrue(recipeCell.waitForExistence(timeout: 10), "example recipes were not imported")
        snapshot("1_recipeList")

        // 2. recipe detail
        recipeCell.tap()
        let start = app.staticTexts["Start"].firstMatch
        XCTAssertTrue(start.waitForExistence(timeout: 5))
        snapshot("2_recipeDetail")

        // 3. schedule
        start.tap()
        let ok = app.navigationBars.buttons["OK"].firstMatch
        XCTAssertTrue(ok.waitForExistence(timeout: 5))
        ok.tap()
        XCTAssertTrue(app.staticTexts[stepName].firstMatch.waitForExistence(timeout: 5))
        snapshot("3_schedule")

        // back to the recipe detail (schedule -> schedule form -> recipe detail)
        goBack()
        goBack()

        // 4. edit recipe, scrolled to the steps
        let edit = app.toolbars.buttons["Edit"].firstMatch
        XCTAssertTrue(edit.waitForExistence(timeout: 5))
        edit.tap()
        let step = app.staticTexts[stepName].firstMatch
        XCTAssertTrue(step.waitForExistence(timeout: 5))
        scrollToTop(step)
        snapshot("4_editRecipe")

        // 5. step detail
        step.tap()
        let ingredient = app.staticTexts[ingredientName].firstMatch
        XCTAssertTrue(ingredient.waitForExistence(timeout: 5))
        snapshot("5_stepDetail")

        // 6. ingredient detail
        ingredient.tap()
        XCTAssertTrue(app.navigationBars[ingredientName].waitForExistence(timeout: 5))
        snapshot("6_ingredientDetail")
    }

    // MARK: - Helpers

    private func goBack() {
        app.navigationBars.firstMatch.buttons.element(boundBy: 0).tap()
        waitForAnimations()
    }

    /// Drags the list up until `element` is just below the navigation bar.
    private func scrollToTop(_ element: XCUIElement) {
        let target = app.navigationBars.firstMatch.frame.maxY + 60
        for _ in 0..<5 where element.frame.minY > target + 20 {
            let start = element.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
            let end = start.withOffset(CGVector(dx: 0, dy: -(element.frame.minY - target)))
            start.press(forDuration: 0.1, thenDragTo: end)
            waitForAnimations()
        }
    }

    private func waitForAnimations() {
        Thread.sleep(forTimeInterval: 1)
    }

    /// Saves a screenshot of the whole screen to `SCREENSHOT_DIR` (if set) and attaches it to the test result.
    private func snapshot(_ name: String) {
        waitForAnimations()
        let screenshot = XCUIScreen.main.screenshot()

        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)

        if let directory = ProcessInfo.processInfo.environment["SCREENSHOT_DIR"], !directory.isEmpty {
            let url = URL(fileURLWithPath: directory).appendingPathComponent("\(name).png")
            do {
                try FileManager.default.createDirectory(atPath: directory, withIntermediateDirectories: true)
                try screenshot.pngRepresentation.write(to: url)
            } catch {
                XCTFail("could not write \(url.path): \(error)")
            }
        }
    }
}
