// SPDX-FileCopyrightText: 2026 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import Foundation
import Testing
import Combine
@testable import BackAppCore
@testable import BakingRecipeFoundation
@testable import GRDB

/// Regression tests for the GRDB 7 migration.
///
/// `databaseSelection` is now a computed property on `Recipe`, `Step` and `Ingredient`,
/// and their `init(row:)` decoders read columns by numeric index, so the round-trip
/// tests insert records with distinct values in every column to pin the selection
/// order to the decoders. Each test gets its own in-memory database, so this suite
/// runs in parallel with the rest of the test target.
struct RecordPersistenceTests {

    let appData = BackAppData.empty()

    // MARK: Full-column round-trips

    @Test func recipeRoundTripsAllColumns() throws {
        var recipe = Recipe(name: "Roundtrip", number: 7)
        recipe.info = "crispy"
        recipe.isFavorite = true
        recipe.difficulty = .hard
        recipe.inverted = true
        recipe.times = Decimal(12)
        // whole seconds, because GRDB stores dates with millisecond precision
        recipe.date = Date(timeIntervalSince1970: 1_700_000_000)
        recipe.imageData = Data([0xDE, 0xAD, 0xBE, 0xEF])

        let inserted = try appData.dbWriter.write { db -> Recipe in
            var copy = recipe
            try copy.insert(db)
            return copy
        }
        let id = try #require(inserted.id)

        let fetched = try #require(appData.record(with: id, of: Recipe.self))
        #expect(fetched == inserted)
    }

    @Test func stepRoundTripsAllColumns() throws {
        let inserted = try appData.dbWriter.write { db -> Step in
            var recipe = Recipe(name: "host recipe", number: 0)
            try recipe.insert(db)

            var superStep = Step(name: "super", recipeId: recipe.id!, number: 0)
            try superStep.insert(db)

            var step = Step(name: "Kneten", duration: 123, temperature: 24.5, notes: "some notes", recipeId: recipe.id!, number: 3)
            step.superStepId = superStep.id
            // the memberwise initializer hardcodes isKneadingStep to false, so set it afterwards
            step.isKneadingStep = true
            step.endTemp = 31.5
            try step.insert(db)
            return step
        }
        let id = try #require(inserted.id)

        let fetched = try #require(appData.record(with: id, of: Step.self))
        #expect(fetched == inserted)
    }

    @Test func ingredientRoundTripsAllColumns() throws {
        let inserted = try appData.dbWriter.write { db -> Ingredient in
            var recipe = Recipe(name: "host recipe", number: 0)
            try recipe.insert(db)

            var step = Step(recipeId: recipe.id!, number: 0)
            try step.insert(db)

            var ingredient = Ingredient(stepId: step.id!, name: "Anstellgut", amount: 42.5, type: .ta150, number: 2)
            ingredient.temperature = 18.25
            try ingredient.insert(db)
            return ingredient
        }
        let id = try #require(inserted.id)

        let fetched = try #require(appData.record(with: id, of: Ingredient.self))
        #expect(fetched == inserted)
    }

    // MARK: Recipe list

    @Test func recipeListRequestOrdersByNumberAndCountsSteps() throws {
        try appData.dbWriter.write { db in
            var second = Recipe(name: "second", number: 1)
            try second.insert(db)
            var first = Recipe(name: "first", number: 0)
            try first.insert(db)

            for number in 0..<2 {
                var step = Step(recipeId: second.id!, number: number)
                try step.insert(db)
            }
            var step = Step(recipeId: first.id!, number: 0)
            try step.insert(db)
        }

        let items = try appData.databaseReader.read { db in
            try BackAppData.RecipeListItem.fetchAll(db, BackAppData.RecipeListItem.request)
        }

        #expect(items.map(\.recipe.name) == ["first", "second"])
        #expect(items.map(\.stepCount) == [1, 2])
    }

    @Test @MainActor func recipeListPublisherEmitsImmediately() throws {
        try appData.dbWriter.write { db in
            var recipe = Recipe(name: "published", number: 0)
            try recipe.insert(db)
            var step = Step(recipeId: recipe.id!, number: 0)
            try step.insert(db)
        }

        var received: [BackAppData.RecipeListItem]?
        let cancellable = appData.recipeListPublisher
            .sink(receiveCompletion: { _ in }) { received = $0 }
        defer { cancellable.cancel() }

        // the .immediate scheduler delivers the first value synchronously on subscription
        let items = try #require(received)
        #expect(items.map(\.recipe.name) == ["published"])
        #expect(items.first?.stepCount == 1)
    }

    // MARK: Concurrency requirements

    /// Compile-time proof of the Sendable conformances added for GRDB 7;
    /// this test fails to build if one of them is dropped.
    @Test func recordTypesRemainSendable() {
        func assertSendable<T: Sendable>(_: T.Type) {}
        assertSendable(Recipe.self)
        assertSendable(Step.self)
        assertSendable(Ingredient.self)
        assertSendable(Difficulty.self)
        assertSendable(Ingredient.Style.self)
        assertSendable(BackAppData.self)
        assertSendable(BackAppData.RecipeListItem.self)
    }
}
