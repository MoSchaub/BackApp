// SPDX-FileCopyrightText: 2026 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import Foundation
import Testing
@testable import BackAppCore
@testable import BakingRecipeFoundation
@testable import GRDB

/// Unit-level replacements for the schedule UI tests: they verify the date math,
/// amount scaling and step counting that the schedule and recipe list screens display.
/// Part of the serialized BackAppCoreTests suite because they share the same database file.
extension BackAppCoreTests {

    /// a non-inverted recipe is scheduled forward from its start date
    /// (replaces the testnormalSchedule UI test)
    @Test
    func normalScheduleDates() throws {
        var recipe = try insertExampleRecipe()
        let start = Date()
        recipe.date = start
        recipe.inverted = false
        appData.update(recipe)

        let reader = appData.databaseReader
        let recipeId = try #require(recipe.id)
        let totalDuration = TimeInterval(recipe.totalDuration(reader: reader) * 60)

        #expect(recipe.startDate(reader: reader) == start)
        #expect(recipe.endDate(reader: reader) == start.addingTimeInterval(totalDuration))

        let steps = appData.notSubsteps(for: recipeId)
        let mischen = try #require(steps.first(where: { $0.name == "Mischen" }))
        let backen = try #require(steps.first(where: { $0.name == "Backen" }))

        #expect(appData.formattedStartDate(for: mischen, with: recipeId) == dateFormatter.string(from: start))
        #expect(appData.formattedStartDate(for: backen, with: recipeId) == dateFormatter.string(from: start.addingTimeInterval(mischen.duration)))
    }

    /// an inverted recipe is scheduled backwards from its end date, both for the current
    /// date and for a date further out
    /// (replaces the testScheduleInverted and testScheduleDiffrentDate UI tests)
    @Test(arguments: [0.0, 10 * 24 * 3600.0])
    func invertedScheduleDates(endDateOffset: TimeInterval) throws {
        var recipe = try insertExampleRecipe()
        let end = Date().addingTimeInterval(endDateOffset)
        recipe.date = end
        recipe.inverted = true
        appData.update(recipe)

        let reader = appData.databaseReader
        let recipeId = try #require(recipe.id)
        let start = end.addingTimeInterval(-TimeInterval(recipe.totalDuration(reader: reader) * 60))

        #expect(recipe.startDate(reader: reader) == start)
        #expect(recipe.endDate(reader: reader) == end)

        let steps = appData.notSubsteps(for: recipeId)
        let mischen = try #require(steps.first(where: { $0.name == "Mischen" }))
        let backen = try #require(steps.first(where: { $0.name == "Backen" }))

        #expect(appData.formattedStartDate(for: mischen, with: recipeId) == dateFormatter.string(from: start))
        #expect(appData.formattedStartDate(for: backen, with: recipeId) == dateFormatter.string(from: start.addingTimeInterval(mischen.duration)))
    }

    /// ingredient amounts scale with the quantity factor: 120 g becomes 1200.0 g for 10 pieces
    /// (replaces the amount assertion of the testScheduleDiffrentTimes UI test)
    @Test
    func scaledIngredientAmounts() throws {
        let recipeId = try insertExampleRecipeAndGetId()
        let mischen = try #require(appData.steps(with: recipeId).first(where: { $0.name == "Mischen" }))
        let stepId = try #require(mischen.id)
        let anstellgut = try #require(appData.ingredients(with: stepId).first(where: { $0.name == "Anstellgut TA 200" }))

        #expect(anstellgut.scaledFormattedAmount(with: 10) == "1200.0 g")
    }

    /// masses are formatted with one decimal and the gramm unit
    /// (replaces the formatting assertion of the testIngredientMassTextConvertBug UI test)
    @Test(arguments: zip([10.5, 120.0, 1200.0], ["10.5 g", "120.0 g", "1200.0 g"]))
    func massFormatting(mass: Double, formatted: String) {
        #expect(mass.formattedMass == formatted)
    }

    /// adding a step to the example recipe raises the recipe list's step count to 3
    /// (replaces the "3 steps" assertion of the testChangingRecipeExample UI test)
    @Test
    func stepCountAfterAddingStep() throws {
        let recipeId = try insertExampleRecipeAndGetId()

        func listStepCount() throws -> Int? {
            try appData.databaseReader.read { db in
                try BackAppData.RecipeListItem.fetchAll(db, BackAppData.RecipeListItem.request)
            }.first(where: { $0.recipe.id == recipeId })?.stepCount
        }

        #expect(try listStepCount() == 2)

        var newStep = Step(name: "testSchritt", duration: 60, recipeId: recipeId, number: 2)
        appData.insert(&newStep)

        #expect(try listStepCount() == 3)
    }
}
