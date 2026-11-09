// SPDX-FileCopyrightText: 2026 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import Foundation
import GRDB
import Testing
@testable import BakingRecipeFoundation
import BakingRecipeStrings

/// Every test gets its own in-memory database, so these suites can run in parallel.
@Suite("Persistence and requests")
struct PersistenceTests {

    @Test("Records round trip through the database with every column")
    func roundTrip() throws {
        let dbQueue = try makeDatabase()
        try dbQueue.write { db throws in
            let recipe = try insertRecipe(db, name: "Brot", number: 4) {
                $0.info = "info"
                $0.isFavorite = true
                $0.difficulty = .hard
                $0.inverted = true
                $0.times = 12
                $0.date = Date(timeIntervalSince1970: 1_700_000_000)
                $0.imageData = Data([0xCA, 0xFE])
            }
            let superStep = try insertStep(db, in: recipe, name: "Hauptteig", number: 0)
            let step = try insertStep(db, in: recipe, name: "Sauerteig", duration: 3600, temperature: 28, superStep: superStep, number: 1) {
                $0.notes = "notes"
                $0.isKneadingStep = true
                $0.endTemp = 24
            }
            let ingredient = try insertIngredient(db, in: step, name: "Wasser", mass: 350, type: .bulkLiquid, temperature: 30, number: 2)

            #expect(try Recipe.fetchOne(db, key: recipe.id) == recipe)
            #expect(try Step.fetchOne(db, key: step.id) == step)
            #expect(try Ingredient.fetchOne(db, key: ingredient.id) == ingredient)
        }
    }

    @Test("Inserting assigns ids")
    func insertAssignsIds() throws {
        let dbQueue = try makeDatabase()
        try dbQueue.write { db throws in
            let recipe = try insertRecipe(db)
            let step = try insertStep(db, in: recipe, name: "s")
            let ingredient = try insertIngredient(db, in: step, name: "i", mass: 1)
            #expect(recipe.id != nil)
            #expect(step.id != nil)
            #expect(ingredient.id != nil)
        }
    }

    @Test("Recipes are ordered by number and favourites can be filtered")
    func recipeRequests() throws {
        let dbQueue = try makeDatabase()
        try dbQueue.write { db throws in
            try insertRecipe(db, name: "c", number: 2)
            try insertRecipe(db, name: "a", number: 0) { $0.isFavorite = true }
            try insertRecipe(db, name: "b", number: 1)

            #expect(try Recipe.all().orderedByNumber.fetchAll(db).map(\.name) == ["a", "b", "c"])
            #expect(try Recipe.all().filterFavorites.fetchAll(db).map(\.name) == ["a"])
        }
    }

    @Test("A step only lists its own ingredients, ordered by number")
    func stepIngredients() throws {
        let dbQueue = try makeDatabase()
        let step = try dbQueue.write { db -> Step in
            let recipe = try insertRecipe(db)
            let step = try insertStep(db, in: recipe, name: "a")
            let other = try insertStep(db, in: recipe, name: "b", number: 1)
            try insertIngredient(db, in: step, name: "second", mass: 1, number: 1)
            try insertIngredient(db, in: other, name: "foreign", mass: 1, number: 0)
            try insertIngredient(db, in: step, name: "first", mass: 1, number: 0)
            return step
        }

        #expect(step.ingredients(reader: dbQueue).map(\.name) == ["first", "second"])
        #expect(step.ingredientCount(reader: dbQueue) == 2)
    }

    @Test("Substeps are direct children only, longest first")
    func sortedSubsteps() throws {
        let dbQueue = try makeDatabase()
        let (_, steps) = try dbQueue.write { try insertMultilayerRecipe($0) }
        let schritt = try #require(steps["Schritt"])

        #expect(schritt.sortedSubsteps(reader: dbQueue).map(\.name) == ["s1sub1", "s1sub2"])
        try dbQueue.read { db throws in
            #expect(schritt.sortedSubsteps(db: db).map(\.name) == ["s1sub1", "s1sub2"])
        }
        #expect(try #require(steps["s2"]).sortedSubsteps(reader: dbQueue).isEmpty)
    }

    @Test("notSubsteps lists only top-level steps in order")
    func notSubsteps() throws {
        let dbQueue = try makeDatabase()
        let (recipe, _) = try dbQueue.write { try insertMultilayerRecipe($0) }
        #expect(recipe.notSubsteps(reader: dbQueue).map(\.name) == ["Schritt", "s2"])
    }

    @Test("Associations reach steps and ingredients across substeps")
    func associations() throws {
        let dbQueue = try makeDatabase()
        try dbQueue.write { db throws in
            let recipe = try insertRecipe(db)
            let step = try insertStep(db, in: recipe, name: "a")
            let sub = try insertStep(db, in: recipe, name: "b", superStep: step, number: 1)
            try insertIngredient(db, in: step, name: "x", mass: 1)
            try insertIngredient(db, in: sub, name: "y", mass: 1)

            #expect(try recipe.request(for: Recipe.steps).fetchCount(db) == 2)
            #expect(try recipe.request(for: Recipe.ingredients).fetchCount(db) == 2)
            #expect(try step.request(for: Step.substeps).fetchAll(db).map(\.name) == ["b"])
        }
    }
}

@Suite("Masses and dough yield")
struct MassTests {

    /// A step with every ingredient style and a substep, so the starter split can be checked:
    /// TA 150 is 2/3 flour + 1/3 water, TA 200 is half flour + half water.
    private func makeMixedStep() throws -> (DatabaseQueue, Recipe, Step) {
        let dbQueue = try makeDatabase()
        let (recipe, step) = try dbQueue.write { db -> (Recipe, Step) in
            let recipe = try insertRecipe(db)
            let step = try insertStep(db, in: recipe, name: "Hauptteig")
            try insertIngredient(db, in: step, name: "Mehl", mass: 100, type: .flour, number: 0)
            try insertIngredient(db, in: step, name: "Wasser", mass: 50, type: .bulkLiquid, number: 1)
            try insertIngredient(db, in: step, name: "Lievito", mass: 150, type: .ta150, number: 2)
            try insertIngredient(db, in: step, name: "Salz", mass: 10, type: .other, number: 3)

            let sub = try insertStep(db, in: recipe, name: "Sauerteig", superStep: step, number: 1)
            try insertIngredient(db, in: sub, name: "Anstellgut", mass: 200, type: .ta200, number: 0)
            return (recipe, step)
        }
        return (dbQueue, recipe, step)
    }

    @Test("totalMass includes substeps")
    func totalMass() throws {
        let (dbQueue, _, step) = try makeMixedStep()
        #expect(step.totalMass(reader: dbQueue) == 510)
        #expect(step.totalFormattedMass(reader: dbQueue) == "510.0 g")
        #expect(step.totalFormattedMass(reader: dbQueue, factor: 2) == "1020.0 g")
    }

    @Test("Starters are split into flour and water")
    func flourAndWater() throws {
        let (dbQueue, _, step) = try makeMixedStep()
        // flour: 100 + 150 * 2/3 + 200 / 2
        #expect(step.flourMass(reader: dbQueue) == 300)
        // water: 50 + 150 * 1/3 + 200 / 2
        #expect(step.waterMass(reader: dbQueue) == 200)

        try dbQueue.read { db throws in
            #expect(try step.flourMass(db: db) == 300)
            #expect(try step.waterMass(db: db) == 200)
        }
    }

    @Test("A recipe's total amount counts substeps once")
    func totalAmount() throws {
        let (dbQueue, recipe, _) = try makeMixedStep()
        try dbQueue.read { db throws in
            #expect(try recipe.totalAmount(db: db) == 510)
            #expect(try recipe.formattedTotalAmount(db: db) == "510.0 g")
        }
    }

    @Test("Dough yield is zero without flour")
    func doughYieldWithoutFlour() throws {
        let dbQueue = try makeDatabase()
        try dbQueue.write { db throws in
            let recipe = try insertRecipe(db)
            let step = try insertStep(db, in: recipe, name: "s")
            try insertIngredient(db, in: step, name: "Wasser", mass: 100, type: .bulkLiquid)

            #expect(try recipe.totalDoughYield(db: db) == 0)
            #expect(try recipe.formattedTotalDoughYield(db: db) == "0.00")
        }
    }

    @Test(
        "Dough yield is the water to flour ratio in English",
        .enabled(if: mainBundleLanguage == "en", "Formula depends on the main bundle's language")
    )
    func doughYieldEnglish() throws {
        let (dbQueue, recipe, _) = try makeMixedStep()
        try dbQueue.read { db throws in
            #expect(try recipe.formattedTotalDoughYield(db: db) == "0.67")
        }
    }

    @Test(
        "Dough yield is the German TA (Teigausbeute) in German",
        .enabled(if: mainBundleLanguage == "de", "Formula depends on the main bundle's language")
    )
    func doughYieldGerman() throws {
        let (dbQueue, recipe, _) = try makeMixedStep()
        try dbQueue.read { db throws in
            #expect(try recipe.formattedTotalDoughYield(db: db) == "166.67")
        }
    }
}

@Suite("Bulk liquid temperature")
struct BulkLiquidTemperatureTests {

    private let flourC = Ingredient.Style.flour.rawValue
    private let waterC = Ingredient.Style.bulkLiquid.rawValue
    private let otherC = Ingredient.Style.other.rawValue

    @Test("Without a liquid the room temperature is returned")
    func withoutLiquid() throws {
        let dbQueue = try makeDatabase()
        let step = try dbQueue.write { db -> Step in
            let step = try insertStep(db, in: try insertRecipe(db), name: "s", temperature: 26)
            try insertIngredient(db, in: step, name: "Mehl", mass: 100, type: .flour)
            return step
        }
        #expect(try step.bulkLiquidTemperature(roomTemp: 21, kneadingHeating: 0, databaseReader: dbQueue) == 21)
    }

    @Test("The liquid is tempered so the mixture reaches the step temperature", arguments: [
        // (step temperature, room temperature, kneading step, kneading heating, mixture target)
        (Double?.some(26), 20.0, false, 0.0, 26.0),
        (Double?.none, 22.0, false, 0.0, 22.0),
        (Double?.some(26), 20.0, true, 4.0, 22.0),
        (Double?.some(26), 20.0, false, 4.0, 26.0), // kneading heating only applies to kneading steps
    ])
    func reachesTarget(stepTemp: Double?, roomTemp: Double, kneading: Bool, heating: Double, target: Double) throws {
        let dbQueue = try makeDatabase()
        let step = try dbQueue.write { db -> Step in
            let step = try insertStep(db, in: try insertRecipe(db), name: "s", temperature: stepTemp) {
                $0.isKneadingStep = kneading
            }
            try insertIngredient(db, in: step, name: "Mehl", mass: 500, type: .flour, number: 0)
            try insertIngredient(db, in: step, name: "Wasser", mass: 350, type: .bulkLiquid, number: 1)
            return step
        }

        let waterTemp = try step.bulkLiquidTemperature(roomTemp: roomTemp, kneadingHeating: heating, databaseReader: dbQueue)

        // Mixing rule: Σ(m·c·T) / Σ(m·c) of all ingredients is the mixture temperature.
        let mixture = (500 * flourC * roomTemp + 350 * waterC * waterTemp) / (500 * flourC + 350 * waterC)
        #expect(abs(mixture - target) < 1e-9)
    }

    @Test("Ingredients with their own temperature are respected")
    func ingredientTemperature() throws {
        let dbQueue = try makeDatabase()
        let step = try dbQueue.write { db -> Step in
            let step = try insertStep(db, in: try insertRecipe(db), name: "s", temperature: 26)
            try insertIngredient(db, in: step, name: "Mehl", mass: 500, type: .flour, temperature: 5, number: 0)
            try insertIngredient(db, in: step, name: "Wasser", mass: 350, type: .bulkLiquid, number: 1)
            return step
        }

        let waterTemp = try step.bulkLiquidTemperature(roomTemp: 20, kneadingHeating: 0, databaseReader: dbQueue)
        let mixture = (500 * flourC * 5 + 350 * waterC * waterTemp) / (500 * flourC + 350 * waterC)
        #expect(abs(mixture - 26) < 1e-9)
    }

    @Test("Nested substeps contribute the heat capacity of all their ingredients")
    func nestedSubsteps() throws {
        let dbQueue = try makeDatabase()
        let step = try dbQueue.write { db -> Step in
            let recipe = try insertRecipe(db)
            let step = try insertStep(db, in: recipe, name: "Hauptteig", temperature: 26)
            try insertIngredient(db, in: step, name: "Wasser", mass: 100, type: .bulkLiquid)
            // The substep's mass lives one level further down and is all "other".
            let sub = try insertStep(db, in: recipe, name: "Vorteig", temperature: 30, superStep: step, number: 1)
            let subsub = try insertStep(db, in: recipe, name: "Brühstück", superStep: sub, number: 2)
            try insertIngredient(db, in: subsub, name: "Saaten", mass: 50, type: .other)
            return step
        }

        let waterTemp = try step.bulkLiquidTemperature(roomTemp: 20, kneadingHeating: 0, databaseReader: dbQueue)
        // The substep enters with its own temperature (30 °C).
        let mixture = (100 * waterC * waterTemp + 50 * otherC * 30) / (100 * waterC + 50 * otherC)
        #expect(abs(mixture - 26) < 1e-9)
    }

    @Test("A starter in a substep has the same heat capacity as a starter used directly", arguments: [
        Ingredient.Style.ta150,
        Ingredient.Style.ta200,
    ])
    func starterInSubstep(starter: Ingredient.Style) throws {
        let dbQueue = try makeDatabase()
        let (direct, nested) = try dbQueue.write { db -> (Step, Step) in
            let recipe = try insertRecipe(db)

            let direct = try insertStep(db, in: recipe, name: "direkt", temperature: 26)
            try insertIngredient(db, in: direct, name: "Wasser", mass: 100, type: .bulkLiquid, number: 0)
            try insertIngredient(db, in: direct, name: "Anstellgut", mass: 200, type: starter, number: 1)

            let nested = try insertStep(db, in: recipe, name: "mit Vorteig", temperature: 26, number: 1)
            try insertIngredient(db, in: nested, name: "Wasser", mass: 100, type: .bulkLiquid)
            // a substep at room temperature that only holds the starter
            let sub = try insertStep(db, in: recipe, name: "Sauerteig", temperature: 20, superStep: nested, number: 2)
            try insertIngredient(db, in: sub, name: "Anstellgut", mass: 200, type: starter)
            return (direct, nested)
        }

        let directTemp = try direct.bulkLiquidTemperature(roomTemp: 20, kneadingHeating: 0, databaseReader: dbQueue)
        let nestedTemp = try nested.bulkLiquidTemperature(roomTemp: 20, kneadingHeating: 0, databaseReader: dbQueue)
        let mixture = (100 * waterC * nestedTemp + 200 * starter.rawValue * 20) / (100 * waterC + 200 * starter.rawValue)
        #expect(abs(mixture - 26) < 1e-9)
        #expect(abs(directTemp - nestedTemp) < 1e-9)
    }

    @Test("An empty substep does not affect the bulk liquid temperature")
    func emptySubstep() throws {
        let dbQueue = try makeDatabase()
        let step = try dbQueue.write { db -> Step in
            let recipe = try insertRecipe(db)
            let step = try insertStep(db, in: recipe, name: "Hauptteig", temperature: 26)
            try insertIngredient(db, in: step, name: "Mehl", mass: 500, type: .flour, number: 0)
            try insertIngredient(db, in: step, name: "Wasser", mass: 350, type: .bulkLiquid, number: 1)
            try insertStep(db, in: recipe, name: "leer", superStep: step, number: 1)
            return step
        }

        let waterTemp = try step.bulkLiquidTemperature(roomTemp: 20, kneadingHeating: 0, databaseReader: dbQueue)
        let mixture = (500 * flourC * 20 + 350 * waterC * waterTemp) / (500 * flourC + 350 * waterC)
        #expect(abs(mixture - 26) < 1e-9)
    }
}

@Suite("Durations and schedule")
struct ScheduleTests {

    @Test("Parallel substeps only add the longest one")
    func durationWithParallelSubsteps() throws {
        let dbQueue = try makeDatabase()
        let (recipe, step) = try dbQueue.write { db -> (Recipe, Step) in
            let recipe = try insertRecipe(db)
            let step = try insertStep(db, in: recipe, name: "a", duration: 600)
            try insertStep(db, in: recipe, name: "short", duration: 300, superStep: step, number: 1)
            try insertStep(db, in: recipe, name: "long", duration: 1200, superStep: step, number: 2)
            try insertStep(db, in: recipe, name: "b", duration: 1200, number: 3)
            return (recipe, step)
        }

        #expect(step.durationWithSubsteps(reader: dbQueue) == 1800)
        try dbQueue.read { db throws in
            #expect(try step.durationWithSubsteps(db: db) == 1800)
        }
        // 1800 s + 1200 s
        #expect(recipe.totalDuration(reader: dbQueue) == 50)
        #expect(recipe.formattedTotalDuration(reader: dbQueue) == 50.formattedDuration)
    }

    @Test("Nested substeps follow the longest chain, not the longest direct substep")
    func durationWithNestedSubsteps() throws {
        let dbQueue = try makeDatabase()
        let (recipe, steps) = try dbQueue.write { try insertMultilayerRecipe($0) }
        let schritt = try #require(steps["Schritt"])

        // The s1sub2 chain (600 + 1800 + 400 s) is longer than the s1sub1 chain (900 + 1200 s),
        // even though s1sub1 itself is longer than s1sub2.
        #expect(schritt.durationWithSubsteps(reader: dbQueue) == 60 + 2800)
        try dbQueue.read { db throws in
            #expect(try schritt.durationWithSubsteps(db: db) == 60 + 2800)
        }
        // 2860 s + 390 s, each step rounded down to whole minutes: 47 + 6
        #expect(recipe.totalDuration(reader: dbQueue) == 53)
    }

    @Test("Nested substep chains are scheduled to finish together")
    func nestedStepStartDates() throws {
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        let dbQueue = try makeDatabase()
        let (recipe, steps) = try dbQueue.write { db in
            try insertMultilayerRecipe(db) { $0.date = date }
        }

        // The longer s1sub2 chain starts at +0 s; the s1sub1 chain starts 700 s later,
        // so both end at +2800 s, when Schritt starts.
        let expectedOffsets: [String: TimeInterval] = [
            "s1sub2subsub": 0, "s1sub2sub": 400, "s1sub2": 2200,
            "s1sub1sub": 700, "s1sub1": 1900,
            "Schritt": 2800, "s2": 2860,
        ]
        for (name, offset) in expectedOffsets {
            let step = try #require(steps[name])
            #expect(
                recipe.formattedStartDate(for: step, reader: dbQueue) == dateFormatter.string(from: date + offset),
                "\(name)"
            )
        }
    }

    @Test("Start and end dates depend on whether the date is inverted", arguments: [false, true])
    func startAndEndDate(inverted: Bool) throws {
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        let dbQueue = try makeDatabase()
        let recipe = try dbQueue.write { db -> Recipe in
            let recipe = try insertRecipe(db) {
                $0.date = date
                $0.inverted = inverted
            }
            try insertStep(db, in: recipe, name: "a", duration: 600)
            try insertStep(db, in: recipe, name: "b", duration: 1200, number: 1)
            return recipe
        }

        let start = recipe.startDate(reader: dbQueue)
        let end = recipe.endDate(reader: dbQueue)
        #expect(end.timeIntervalSince(start) == 1800)
        #expect((inverted ? end : start) == date)
    }

    @Test("Parallel substeps are scheduled to finish together")
    func stepStartDates() throws {
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        let dbQueue = try makeDatabase()
        let (recipe, steps) = try dbQueue.write { db -> (Recipe, [Step]) in
            let recipe = try insertRecipe(db) { $0.date = date }
            let main = try insertStep(db, in: recipe, name: "main", duration: 600)
            let long = try insertStep(db, in: recipe, name: "long", duration: 1200, superStep: main, number: 1)
            let short = try insertStep(db, in: recipe, name: "short", duration: 300, superStep: main, number: 2)
            let next = try insertStep(db, in: recipe, name: "next", duration: 60, number: 3)
            return (recipe, [main, long, short, next])
        }

        // long starts first, short starts so both end at +1200 s, then main, then next.
        let expectedOffsets: [TimeInterval] = [1200, 0, 900, 1800]
        for (step, offset) in zip(steps, expectedOffsets) {
            #expect(
                recipe.formattedStartDate(for: step, reader: dbQueue) == dateFormatter.string(from: date + offset),
                "\(step.name)"
            )
        }
    }

    @Test("An unknown step has no start date")
    func unknownStepStartDate() throws {
        let dbQueue = try makeDatabase()
        let recipe = try dbQueue.write { try insertRecipe($0) }
        let stranger = Step(name: "stranger", recipeId: 99, number: 0)
        #expect(recipe.formattedStartDate(for: stranger, reader: dbQueue) == "error")
    }

    @Test("Reordering runs the longest substep chain first and renumbers the steps")
    func reorderedSteps() throws {
        let dbQueue = try makeDatabase()
        let (recipe, _) = try dbQueue.write { try insertMultilayerRecipe($0) }

        let reordered = recipe.reorderedSteps(writer: dbQueue)
        #expect(reordered.map(\.name) == ["s1sub2subsub", "s1sub2sub", "s1sub1sub", "s1sub1", "s1sub2", "Schritt", "s2"])
        #expect(reordered.map(\.number) == Array(1...7))
    }
}

@Suite("Duplicating and exporting")
struct DuplicationTests {

    @Test("Duplicating copies steps, substeps and ingredients with new ids")
    func duplicate() throws {
        let dbQueue = try makeDatabase()
        let original = try dbQueue.write { db -> Recipe in
            let recipe = try insertRecipe(db, name: "Brot")
            let step = try insertStep(db, in: recipe, name: "Hauptteig", duration: 600)
            try insertIngredient(db, in: step, name: "Mehl", mass: 500, type: .flour)
            let sub = try insertStep(db, in: recipe, name: "Sauerteig", duration: 1200, superStep: step, number: 1)
            try insertIngredient(db, in: sub, name: "Anstellgut", mass: 50, type: .ta200)
            return recipe
        }

        original.duplicate(writer: dbQueue)

        try dbQueue.read { db throws in
            let recipes = try Recipe.fetchAll(db)
            try #require(recipes.count == 2)
            let copy = try #require(recipes.first { $0.id != original.id })
            #expect(copy.name == original.name)

            let copiedSteps = try copy.steps.fetchAll(db)
            #expect(copiedSteps.map(\.name).sorted() == ["Hauptteig", "Sauerteig"])

            // The substep points at the copied super step, not the original one.
            let copiedMain = try #require(copiedSteps.first { $0.name == "Hauptteig" })
            let copiedSub = try #require(copiedSteps.first { $0.name == "Sauerteig" })
            #expect(copiedMain.superStepId == nil)
            #expect(copiedSub.superStepId == copiedMain.id)

            #expect(try copy.request(for: Recipe.ingredients).fetchCount(db) == 2)
            #expect(try copy.totalAmount(db: db) == original.totalAmount(db: db))
            #expect(try copy.compactFormattedTotalDuration(db: db) == original.compactFormattedTotalDuration(db: db))
        }
    }

    @Test("The export text lists steps, ingredients, notes and the end")
    func exportText() throws {
        let dbQueue = try makeDatabase()
        let recipe = try dbQueue.write { db -> Recipe in
            let recipe = try insertRecipe(db, name: "Cracker") { $0.times = 2 }
            let step = try insertStep(db, in: recipe, name: "Mischen", duration: 120) { $0.notes = "gut mischen" }
            try insertIngredient(db, in: step, name: "Mehl", mass: 50, type: .flour)
            try insertStep(db, in: recipe, name: "Backen", duration: 1080, number: 1)
            return recipe
        }

        let text = recipe.text(roomTemp: 20, scaleFactor: 2, kneadingHeating: 0, reader: dbQueue)
        let lines = text.components(separatedBy: "\n")

        #expect(lines.first == "Cracker 4 \(Strings.pieces)")
        #expect(lines.contains { $0.hasPrefix("Mischen ") })
        #expect(lines.contains("\tMehl: 100.0 g "))
        #expect(lines.contains("gut mischen"))
        #expect(lines.contains { $0.hasPrefix("Backen ") })
        #expect(lines.last == "\(Strings.EditButton_Done): \(dateFormatter.string(from: recipe.endDate(reader: dbQueue)))")
    }
}
