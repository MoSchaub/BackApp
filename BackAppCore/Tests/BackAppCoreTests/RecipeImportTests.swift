// SPDX-FileCopyrightText: 2026 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import Foundation
import Testing
@testable import BackAppCore
@testable import BakingRecipeFoundation
import BakingRecipeStrings

/// Regression tests for importing recipe files (issue #35).
///
/// `open(_:)` reports its outcome through the global `inputAlertTitle` /
/// `inputAlertMessage` and the `.alertShouldBePresented` notification, so the
/// user has to be told about every import, including ones that fail.
/// Serialized because those alert globals are shared.
@Suite(.serialized)
struct RecipeImportTests {

    let appData = BackAppData.empty()

    init() {
        inputAlertTitle = ""
        inputAlertMessage = ""
    }

    @Test("Opening a valid recipe file imports it and reports success")
    func openingValidFileReportsSuccess() async throws {
        let url = try writeTemporaryFile(contents: """
        {"recipes": [{"name": "Imported Bread", "number": 0, "steps": [
            {"name": "Mix", "duration": 600, "number": 0,
             "ingredients": [{"name": "Flour", "mass": 500, "number": 0, "type": 0}]}
        ]}]}
        """)

        let alert = await openAndWaitForAlert(url)

        #expect(appData.allRecipes.map(\.name) == ["Imported Bread"])
        #expect(appData.allIngredients.map(\.name) == ["Flour"])
        #expect(alert.title == Strings.success)
        #expect(alert.message == Strings.recipesImported)
    }

    @Test("Opening a file that cannot be read reports an error")
    func openingUnreadableFileReportsError() async {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("missing-\(UUID().uuidString).bakingAppRecipe")

        let alert = await openAndWaitForAlert(url)

        #expect(appData.allRecipes.isEmpty)
        #expect(alert.title == Strings.Alert_Error)
        #expect(alert.message.isEmpty == false, "The user should be told why nothing was imported")
    }

    @Test("Opening a file without recipes reports an error")
    func openingFileWithoutRecipesReportsError() async throws {
        let url = try writeTemporaryFile(contents: #"{"something": "else"}"#)

        let alert = await openAndWaitForAlert(url)

        #expect(appData.allRecipes.isEmpty)
        #expect(alert.title == Strings.Alert_Error)
        #expect(alert.message.isEmpty == false, "The user should be told why nothing was imported")
    }

    // MARK: Helpers

    private func writeTemporaryFile(contents: String) throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(UUID().uuidString).bakingAppRecipe")
        try Data(contents.utf8).write(to: url)
        return url
    }

    /// Opens `url` and waits until the import posts `.alertShouldBePresented` for it,
    /// then returns the alert it asked the UI to show.
    private func openAndWaitForAlert(_ url: URL) async -> (title: String, message: String) {
        await withCheckedContinuation { continuation in
            var token: NSObjectProtocol?
            token = NotificationCenter.default.addObserver(forName: .alertShouldBePresented, object: nil, queue: nil) { notification in
                // other suites may import concurrently, so ignore alerts for other files
                if let openedURL = notification.object as? URL, openedURL != url { return }
                guard let observer = token else { return }
                NotificationCenter.default.removeObserver(observer)
                continuation.resume(returning: (inputAlertTitle, inputAlertMessage))
            }
            appData.open(url)
        }
    }
}
