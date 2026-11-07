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

    /// How long to wait for a screen. Generous because Xcode Cloud's simulators are slow.
    private let timeout: TimeInterval = 10

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
        XCTAssertTrue(recipeCell.waitForExistence(timeout: timeout), "example recipes were not imported")
        snapshot("1_recipeList")

        // 2. recipe detail
        recipeCell.tap()
        let start = app.staticTexts["Start"].firstMatch
        XCTAssertTrue(start.waitForExistence(timeout: timeout))
        snapshot("2_recipeDetail")

        // 3. schedule
        start.tap()
        // The confirm button is titled "OK" but iOS 26 renders it as a checkmark whose
        // accessibility label is "Done", so match either label.
        let ok = app.navigationBars.buttons.matching(
            NSPredicate(format: "label == %@ OR label == %@", "OK", "Done")).firstMatch
        XCTAssertTrue(ok.waitForExistence(timeout: timeout))
        ok.tap()
        ok.tap()
        XCTAssertTrue(app.staticTexts[stepName].firstMatch.waitForExistence(timeout: timeout))
        snapshot("3_schedule")

        // back to the recipe detail (schedule -> schedule form -> recipe detail)
        goBack()
        goBack()

        // 4. edit recipe, scrolled to the steps
        // iOS 26 no longer nests the bottom toolbar buttons under a toolbar element,
        // so query the Edit button directly.
        let edit = app.buttons["Edit"].firstMatch
        XCTAssertTrue(edit.waitForExistence(timeout: timeout))
        edit.tap()
        let step = app.staticTexts[stepName].firstMatch
        XCTAssertTrue(step.waitForExistence(timeout: timeout))
        scrollToTop(step)
        snapshot("4_editRecipe")

        // 5. step detail
        step.tap()
        let ingredient = app.staticTexts[ingredientName].firstMatch
        XCTAssertTrue(ingredient.waitForExistence(timeout: timeout))
        snapshot("5_stepDetail")

        // 6. ingredient detail
        // the tap is lost if the cell isn't hittable yet, and then the screen never opens
        waitUntilHittable(ingredient)
        ingredient.tap()
        XCTAssertTrue(app.navigationBars[ingredientName].waitForExistence(timeout: timeout))
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

    private func waitUntilHittable(_ element: XCUIElement, file: StaticString = #filePath, line: UInt = #line) {
        let hittable = XCTNSPredicateExpectation(predicate: NSPredicate(format: "isHittable == true"), object: element)
        XCTAssertEqual(XCTWaiter().wait(for: [hittable], timeout: timeout), .completed,
                       "\(element) did not become hittable", file: file, line: line)
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
