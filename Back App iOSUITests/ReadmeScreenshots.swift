// SPDX-FileCopyrightText: 2026 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import XCTest
import BakingRecipeStrings

/// Takes the screenshots used in the README and in the App Store.
///
/// The app is launched with `-screenshotMode`, which replaces the database with the
/// example recipes bundled with the app, so the screenshots always show the same data.
///
/// Run it with
/// - `scripts/screenshots/take_screenshots.sh` for the README (English, iPhone, framed into `images/`)
/// - `scripts/screenshots/make_screenshots.sh` for the App Store (every language and App Store device)
///
/// The scripts pass these environment variables (as `TEST_RUNNER_<name>`):
/// - `SCREENSHOT_DIR`: where the PNGs are written; they are also attached to the test result
/// - `SCREENSHOT_LANGUAGE`: `en` (default) or `de`
/// - `SCREENSHOT_ORIENTATION`: `portrait` (default) or `landscape`, e.g. for the iPad
/// - `SCREENSHOT_CAPTURE`: `device` (default) or `host`. On the iPhone Duo `XCUIScreen.main`
///   isn't necessarily the display that is showing, so with `host` the test asks
///   `capture.sh` for each screenshot, which takes it with duoctl.
final class ReadmeScreenshots: XCTestCase {

    /// Texts of the first bundled example recipe (`ExampleRecipeFiles/<lang>/1<lang>.bakingAppRecipe`).
    /// Labels are matched by prefix because some German names end with a space.
    private struct ExampleTexts {
        let recipe: String
        let step: String
        let ingredient: String
        /// `Strings.startRecipe`
        let start: String
        let locale: String
    }

    private static let texts: [String: ExampleTexts] = [
        "en": ExampleTexts(recipe: "Simple cut rolls", step: "Main dough", ingredient: "Wheat bread flour",
                           start: "Start", locale: "en_US"),
        "de": ExampleTexts(recipe: "Schnittbrötchen", step: "Hauptteig", ingredient: "Weizenmehl 812",
                           start: "Starten", locale: "de_DE"),
    ]

    /// How long to wait for a screen. Generous because Xcode Cloud's simulators are slow.
    private let timeout: TimeInterval = 10

    private var app: XCUIApplication!

    private var environment: [String: String] { ProcessInfo.processInfo.environment }
    private var language: String { environment["SCREENSHOT_LANGUAGE"] ?? "en" }
    private var text: ExampleTexts { Self.texts[language] ?? Self.texts["en"]! }
    private var capturesOnHost: Bool { environment["SCREENSHOT_CAPTURE"] == "host" }

    override func setUpWithError() throws {
        continueAfterFailure = false

        // Rotation has no effect on the iPhone Duo (and isn't needed: its inner display is
        // landscape by default), so only rotate when the test takes the screenshots itself.
        if !capturesOnHost {
            XCUIDevice.shared.orientation =
                environment["SCREENSHOT_ORIENTATION"] == "landscape" ? .landscapeLeft : .portrait
        }

        app = XCUIApplication()
        app.launchArguments += ["-screenshotMode", "-AppleLanguages", "(\(language))", "-AppleLocale", text.locale]
        app.launch()
    }

    func testTakeReadmeScreenshots() throws {
        // 1. recipe list
        let recipeCell = staticText(text.recipe)
        XCTAssertTrue(recipeCell.waitForExistence(timeout: timeout), "example recipes were not imported")
        snapshot("1_recipeList")

        // 2. recipe detail
        recipeCell.tap()
        let start = staticText(text.start)
        XCTAssertTrue(start.waitForExistence(timeout: timeout))
        snapshot("2_recipeDetail")

        // 3. schedule
        start.tap()
        let ok = app.buttons[AccessibilityID.confirmScheduleButton].firstMatch
        XCTAssertTrue(ok.waitForExistence(timeout: timeout))
        ok.tap()
        // the first tap can only end editing of the quantity field
        waitForAnimations()
        if ok.exists && ok.isHittable {
            ok.tap()
        }
        XCTAssertTrue(staticText(text.step).waitForExistence(timeout: timeout))
        snapshot("3_schedule")

        // back to the recipe detail (schedule -> schedule form -> recipe detail)
        goBack()
        goBack()

        // 4. edit recipe, scrolled to the steps
        let edit = app.buttons[AccessibilityID.editRecipeButton].firstMatch
        XCTAssertTrue(edit.waitForExistence(timeout: timeout))
        edit.tap()
        let step = staticText(text.step)
        XCTAssertTrue(step.waitForExistence(timeout: timeout))
        scrollToTop(step)
        snapshot("4_editRecipe")

        // 5. step detail
        step.tap()
        let ingredient = staticText(text.ingredient)
        XCTAssertTrue(ingredient.waitForExistence(timeout: timeout))
        snapshot("5_stepDetail")

        // 6. ingredient detail
        // the ingredient can be below the screen edge, e.g. on iPhone 16 with iOS 27.
        // Tap the cell rather than the label, so the tap selects the row.
        let ingredientCell = app.cells.containing(labelBeginningWith(text.ingredient)).firstMatch
        scrollIntoView(ingredientCell)
        tap(ingredientCell, until: app.navigationBars.matching(identifierBeginningWith(text.ingredient)).firstMatch)
        snapshot("6_ingredientDetail")
    }

    // MARK: - Elements

    private func labelBeginningWith(_ prefix: String) -> NSPredicate {
        NSPredicate(format: "label BEGINSWITH %@", prefix)
    }

    private func identifierBeginningWith(_ prefix: String) -> NSPredicate {
        NSPredicate(format: "identifier BEGINSWITH %@", prefix)
    }

    private func staticText(_ prefix: String) -> XCUIElement {
        app.staticTexts.matching(labelBeginningWith(prefix)).firstMatch
    }

    /// The navigation bar of the screen being shown. In the iPad's split view the recipe list
    /// has its own navigation bar on the left, so take the right-most one.
    private var currentNavigationBar: XCUIElement {
        let bars = app.navigationBars.allElementsBoundByIndex.filter { $0.exists && !$0.frame.isEmpty }
        return bars.max { $0.frame.minX < $1.frame.minX } ?? app.navigationBars.firstMatch
    }

    /// The table that shows `element` (the iPad's split view has two).
    private func table(showing element: XCUIElement) -> XCUIElement {
        let x = element.frame.midX
        return app.tables.allElementsBoundByIndex.first { $0.frame.minX <= x && x <= $0.frame.maxX }
            ?? app.tables.firstMatch
    }

    // MARK: - Helpers

    private func goBack() {
        currentNavigationBar.buttons.element(boundBy: 0).tap()
        waitForAnimations()
    }

    /// Drags the list up until `element` is just below the navigation bar.
    private func scrollToTop(_ element: XCUIElement) {
        let target = currentNavigationBar.frame.maxY + 60
        for _ in 0..<5 where element.frame.minY > target + 20 {
            let start = element.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
            let end = start.withOffset(CGVector(dx: 0, dy: -(element.frame.minY - target)))
            start.press(forDuration: 0.1, thenDragTo: end)
            waitForAnimations()
        }
    }

    /// Swipes the list up until `element` can be tapped and is clear of the bottom screen edge.
    /// XCUITest doesn't reliably scroll a table cell into view before tapping it,
    /// and a tap on a row right at the edge (behind the home indicator) is lost.
    /// Stops early when the list can't scroll any further.
    private func scrollIntoView(_ element: XCUIElement, file: StaticString = #filePath, line: UInt = #line) {
        let bottom = app.windows.firstMatch.frame.maxY - 100
        for _ in 0..<5 {
            if element.isHittable && element.frame.maxY <= bottom { break }
            let frameBefore = element.frame
            table(showing: element).swipeUp(velocity: .slow)
            waitForAnimations()
            if element.frame == frameBefore { break }
        }
        XCTAssertTrue(element.isHittable, "\(element) is not on screen", file: file, line: line)
    }

    /// Taps `element` and waits for `screen` to appear.
    /// On slow simulators a tap right after scrolling can be lost (it only stops the scrolling),
    /// so tap once more if `element` is still on screen.
    private func tap(_ element: XCUIElement, until screen: XCUIElement, file: StaticString = #filePath, line: UInt = #line) {
        element.tap()
        if !screen.waitForExistence(timeout: timeout / 2), element.isHittable {
            waitForAnimations()
            element.tap()
        }
        XCTAssertTrue(screen.waitForExistence(timeout: timeout), "\(screen) did not appear after tapping \(element)",
                      file: file, line: line)
    }

    private func waitForAnimations() {
        Thread.sleep(forTimeInterval: 1)
    }

    // MARK: - Screenshots

    /// Saves a screenshot of the whole screen to `SCREENSHOT_DIR` (if set) and attaches it to the test result.
    private func snapshot(_ name: String) {
        waitForAnimations()

        guard let directory = environment["SCREENSHOT_DIR"], !directory.isEmpty else {
            attach(XCTAttachment(screenshot: XCUIScreen.main.screenshot()), name: name)
            return
        }
        let url = URL(fileURLWithPath: directory).appendingPathComponent("\(name).png")

        if capturesOnHost {
            requestHostScreenshot(at: url)
            if FileManager.default.fileExists(atPath: url.path) {
                attach(XCTAttachment(contentsOfFile: url), name: name)
            }
        } else {
            let screenshot = XCUIScreen.main.screenshot()
            attach(XCTAttachment(screenshot: screenshot), name: name)
            do {
                try FileManager.default.createDirectory(atPath: directory, withIntermediateDirectories: true)
                try screenshot.pngRepresentation.write(to: url)
            } catch {
                XCTFail("could not write \(url.path): \(error)")
            }
        }
    }

    private func attach(_ attachment: XCTAttachment, name: String) {
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    /// Asks `capture.sh` for a screenshot: drops a `<name>.request` file next to the target,
    /// which the script answers with `duoctl screenshot` before deleting the request.
    private func requestHostScreenshot(at url: URL) {
        let request = url.deletingPathExtension().appendingPathExtension("request")
        try? FileManager.default.removeItem(at: url)
        FileManager.default.createFile(atPath: request.path, contents: nil)

        let deadline = Date().addingTimeInterval(60)
        while Date() < deadline {
            if !FileManager.default.fileExists(atPath: request.path) {
                XCTAssertTrue(FileManager.default.fileExists(atPath: url.path),
                              "capture.sh could not take \(url.lastPathComponent)")
                return
            }
            Thread.sleep(forTimeInterval: 0.2)
        }
        XCTFail("timed out waiting for capture.sh to take \(url.lastPathComponent)")
    }
}
