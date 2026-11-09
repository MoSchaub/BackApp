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
/// `open(_:)` returns the outcome of every import, including ones that fail,
/// so the user can be told about it. Each test uses its own in-memory database.
struct RecipeImportTests {

    let appData = BackAppData.empty()

    @Test("Opening a valid recipe file imports it and reports success")
    func openingValidFileReportsSuccess() async throws {
        let url = try writeTemporaryFile(contents: """
        {"recipes": [{"name": "Imported Bread", "number": 0, "steps": [
            {"name": "Mix", "duration": 600, "number": 0,
             "ingredients": [{"name": "Flour", "mass": 500, "number": 0, "type": 0}]}
        ]}]}
        """)

        let result = await appData.open(url)

        #expect(result == .imported)
        #expect(appData.allRecipes.map(\.name) == ["Imported Bread"])
        #expect(appData.allIngredients.map(\.name) == ["Flour"])
        #expect(result.alertTitle == Strings.success)
        #expect(result.alertMessage == Strings.recipesImported)
    }

    @Test("Opening a file that cannot be read reports an error")
    func openingUnreadableFileReportsError() async {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("missing-\(UUID().uuidString).bakingAppRecipe")

        let result = await appData.open(url)

        #expect(result == .unreadable)
        #expect(appData.allRecipes.isEmpty)
        #expect(result.alertTitle == Strings.Alert_Error)
        #expect(result.alertMessage == Strings.importFileUnreadable)
    }

    @Test("Opening a file without recipes reports an error")
    func openingFileWithoutRecipesReportsError() async throws {
        let url = try writeTemporaryFile(contents: #"{"something": "else"}"#)

        let result = await appData.open(url)

        #expect(result == .noRecipes)
        #expect(appData.allRecipes.isEmpty)
        #expect(result.alertTitle == Strings.Alert_Error)
        #expect(result.alertMessage == Strings.importFileContainsNoRecipes)
    }

    // MARK: Helpers

    private func writeTemporaryFile(contents: String) throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(UUID().uuidString).bakingAppRecipe")
        try Data(contents.utf8).write(to: url)
        return url
    }
}
