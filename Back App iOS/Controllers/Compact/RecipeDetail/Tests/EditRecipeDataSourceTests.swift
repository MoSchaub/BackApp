// SPDX-FileCopyrightText: 2026 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import Foundation
import Testing
import GRDB
@testable import Back_App
@testable import BackAppCore
import BakingRecipeFoundation

/// Moving a step row must rebuild the edit recipe table from the database,
/// otherwise the snapshot keeps the old order and substeps don't follow their superstep.
///
/// Uses its own in-memory database: the other app tests reset the shared database
/// with `BackAppData.shared(includeTestingRecipe:)` while this test waits for the move.
@MainActor
struct EditRecipeDataSourceTests {

    let appData: BackAppData
    let recipeId: Int64
    let sut: EditRecipeViewController

    /// recipe with the steps "Vorteig", "Hauptteig" and "Sauerteig" (substep of "Hauptteig"),
    /// so the table shows `["Vorteig", "Sauerteig", "Hauptteig"]`
    init() throws {
        appData = try BackAppData(DatabaseQueue())

        var recipe = Recipe(name: "Reorder", number: 0)
        appData.insert(&recipe)
        recipeId = try #require(recipe.id)

        var vorteig = Step(name: "Vorteig", recipeId: recipeId, number: 0)
        appData.insert(&vorteig)
        var hauptteig = Step(name: "Hauptteig", recipeId: recipeId, number: 1)
        appData.insert(&hauptteig)
        var sauerteig = Step(name: "Sauerteig", recipeId: recipeId, number: 2)
        sauerteig.superStepId = try #require(hauptteig.id)
        appData.insert(&sauerteig)

        sut = EditRecipeViewController(recipeId: recipeId, creating: false, appData: appData)
        sut.beginAppearanceTransition(true, animated: false)
    }

    /// names of the step rows currently in the table
    private var displayedSteps: [String] {
        sut.dataSource.snapshot().itemIdentifiers(inSection: .steps).compactMap { ($0 as? StepItem)?.step.formattedName }
    }

    /// names of the steps in the order they are stored in the database
    private var storedSteps: [String] {
        appData.reorderedSteps(for: recipeId).map(\.formattedName)
    }

    /// moves a row like UIKit does after a drag and waits for the table to show `expected`
    private func moveRow(from source: Int, to destination: Int, expecting expected: [String], timeout: TimeInterval = 3) async throws {
        let section = try #require(RecipeDetailSection.allCases.firstIndex(of: .steps))
        sut.dataSource.tableView(sut.tableView, moveRowAt: IndexPath(row: source, section: section), to: IndexPath(row: destination, section: section))

        let deadline = Date().addingTimeInterval(timeout)
        while displayedSteps != expected, Date() < deadline {
            try await Task.sleep(nanoseconds: 50_000_000)
        }
    }

    @Test
    func movingRowRefreshesSnapshot() async throws {
        #expect(displayedSteps == ["Vorteig", "Sauerteig", "Hauptteig"])

        // dragging the superstep to the top takes its substep along
        try await moveRow(from: 2, to: 0, expecting: ["Sauerteig", "Hauptteig", "Vorteig"])

        #expect(displayedSteps == ["Sauerteig", "Hauptteig", "Vorteig"])
        #expect(displayedSteps == storedSteps)
    }

    @Test
    func secondMoveUsesRefreshedRows() async throws {
        try await moveRow(from: 2, to: 0, expecting: ["Sauerteig", "Hauptteig", "Vorteig"])
        #expect(displayedSteps == ["Sauerteig", "Hauptteig", "Vorteig"])

        // the rows of the refreshed table must point at the right steps again
        try await moveRow(from: 2, to: 0, expecting: ["Vorteig", "Sauerteig", "Hauptteig"])

        #expect(displayedSteps == ["Vorteig", "Sauerteig", "Hauptteig"])
        #expect(displayedSteps == storedSteps)
    }
}
