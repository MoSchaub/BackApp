// SPDX-FileCopyrightText: 2026 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import Foundation
import Testing
@testable import BackAppCore
@testable import BakingRecipeFoundation

/// Regression tests for issue #37 "Reordering steps does not work anymore".
///
/// The edit recipe table lists steps in `reorderedSteps(for:)` order (substeps directly before
/// their superstep) and passes the dragged row indices to `moveStep(with:from:to:)`.
/// Part of the serialized BackAppCoreTests suite because they share the same database file.
extension BackAppCoreTests {

    /// Inserts the complex example (substep "Sauerteig" of "Hauptteig") plus a trailing top-level
    /// step "Backen", so the table shows `["Sauerteig", "Hauptteig", "Backen"]`.
    func insertComplexRecipeWithTrailingStep() throws -> Int64 {
        let recipeId = try insertComplexRecipeAndGetId()
        let lastNumber = try #require(appData.steps(with: recipeId).map(\.number).max())
        var backen = Step(name: "Backen", recipeId: recipeId, number: lastNumber + 1)
        appData.insert(&backen)

        #expect(appData.reorderedSteps(for: recipeId).map(\.formattedName) == ["Sauerteig", "Hauptteig", "Backen"])
        return recipeId
    }

    @Test(arguments: [
        // dropping the last step in front of the substep
        (source: 2, destination: 0, expected: ["Backen", "Sauerteig", "Hauptteig"]),
        // dropping the last step between the substep and its superstep
        (source: 2, destination: 1, expected: ["Backen", "Sauerteig", "Hauptteig"]),
        // dropping the superstep behind the last step takes its substep along
        (source: 1, destination: 2, expected: ["Backen", "Sauerteig", "Hauptteig"]),
    ])
    func movingStepAroundSubstep(source: Int, destination: Int, expected: [String]) async throws {
        let recipeId = try insertComplexRecipeWithTrailingStep()

        try await appData.moveStep(with: recipeId, from: source, to: destination)

        #expect(appData.reorderedSteps(for: recipeId).map(\.formattedName) == expected)
    }

    /// After a move, the stored step numbers must follow the displayed order,
    /// otherwise the row indices of the next drag point at the wrong steps.
    @Test
    func storedNumbersMatchDisplayedOrderAfterMove() async throws {
        let recipeId = try insertComplexRecipeWithTrailingStep()
        let expected = ["Backen", "Sauerteig", "Hauptteig"]

        try await appData.moveStep(with: recipeId, from: 2, to: 0)

        let displayed = appData.reorderedSteps(for: recipeId).map(\.formattedName)
        #expect(displayed == expected)
        #expect(appData.steps(with: recipeId).map(\.formattedName) == displayed)

        // a second drag based on the displayed rows must work as well
        try await appData.moveStep(with: recipeId, from: 0, to: 2)
        #expect(appData.reorderedSteps(for: recipeId).map(\.formattedName) == ["Sauerteig", "Hauptteig", "Backen"])
    }
}
