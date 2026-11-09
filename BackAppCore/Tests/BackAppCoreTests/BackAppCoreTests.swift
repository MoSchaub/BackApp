// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import Foundation
import Testing
@testable import BackAppCore
@testable import BakingRecipeFoundation
@testable import GRDB

// serialized because every test opens its own DatabasePool on the same db.sqlite file;
// parallel opens race on `PRAGMA journal_mode = WAL` and crash with SQLite error 5
@Suite(.serialized)
struct BackAppCoreTests {

    var appData: BackAppData

    // Per-test setup: Swift Testing creates a new instance for each test.
    init() {
        // Strings.* resolve lazily via NSLocalizedString, so setting AppleLanguages here
        // is picked up on first access and forces English output.
        UserDefaults.standard.set(["en"], forKey: "AppleLanguages")
        // Locale.current cannot be changed at runtime, so use the production override hook
        // to make temperature formatting deterministic (en_US -> °F).
        MeasurementFormatting.localeOverride = Locale(identifier: "en_US")
        // Nuke the database before each test instance
        self.appData = BackAppData.shared(resetDatabase: true)
    }

    // Helper to reduce duplication in schema tests
    func assertTableSchema(existsName: String, columnsName: String? = nil, expectedColumns: Set<String>, sourceLocation: SourceLocation = #_sourceLocation) throws {
        // Given an empty database
        let dbQueue = try DatabaseQueue()

        // When we instantiate BackAppData
        _ = try BackAppData(dbQueue)

        // Then the table exists with its columns
        try dbQueue.read { db in
            #expect(try db.tableExists(existsName), sourceLocation: sourceLocation)
            let columns = try db.columns(in: columnsName ?? existsName)
            let columnNames = Set(columns.map { $0.name })
            #expect(columnNames == expectedColumns, sourceLocation: sourceLocation)
        }
    }

    @Test
    func recipeDatabaseSchema() throws {
        try assertTableSchema(
            existsName: "Recipe",
            expectedColumns: ["id", "name", "info", "isFavorite", "difficulty", "inverted", "times", "date", "imageData", "number"]
        )
    }

    @Test
    func stepDatabaseSchema() throws {
        try assertTableSchema(
            existsName: "Step",
            expectedColumns: ["id", "name", "duration", "isKneadingStep", "temperature", "notes", "recipeId", "superStepId", "number", "endTemp"]
        )
    }

    @Test
    func ingredientDatabaseSchema() throws {
        try assertTableSchema(
            existsName: "ingredient",
            columnsName: "Ingredient",
            expectedColumns: ["id", "name", "temperature", "mass", "c", "stepId", "number"]
        )
    }

    @Test
    func insertingExample() throws {
        try insert(recipeTransfer: Recipe.example)
    }

    @Test
    func insertingComplexRecipe() throws {
        try insert(recipeTransfer: Recipe.complexExample(number: 0))
    }

    @Test
    func insertingMultilayerRecipe() throws {
        try insert(recipeTransfer: Recipe.multilayerSubstepExample(number: 0), complex: true)

        let fetchedRecipe = try appData.databaseReader.read { db in
            try Recipe.filter(Recipe.Columns.name == "multilayer").fetchOne(db)
        }
        let recipe = try #require(fetchedRecipe)
        let recipeId = try #require(recipe.id)

        //verify that the substeps are correct
        let step = try #require(appData.steps(with: recipeId).first)
        let stepId = try #require(step.id)
        #expect(appData.sortedSubsteps(for: stepId).count == 2)
    }

    func insert(recipeTransfer: RecipeTransferType, complex: Bool = false, sourceLocation: SourceLocation = #_sourceLocation) throws {
        var recipe = recipeTransfer.recipe
        let appData = BackAppData.shared

        appData.insert(&recipe)
        #expect(try appData.databaseReader.read(recipe.exists), sourceLocation: sourceLocation)
        let recipeId = try #require(recipe.id, sourceLocation: sourceLocation)

        var previousStepId: Int64?

        for stepIngredients in recipeTransfer.stepIngredients {
            var step = stepIngredients.step
            step.recipeId = recipeId

            //check if there is any superstep id that is not nil. any superstep id is used as a notation to say that the step is suposed to be substep of the previously inserted step. This means the superstepid is not set if it was nil before.
            if !complex, step.superStepId != nil, let previousStepId = previousStepId {
                step.superStepId = previousStepId
            } else if complex, let superStepId = step.superStepId, let superStep = appData.steps(with: step.recipeId).first(where: { $0.number == superStepId }), let newId = superStep.id  { // check only steps of the recipe to improve efficiency and don't missmatch the superstep.
                step.superStepId = newId
            }
            appData.insert(&step)

            #expect(try appData.databaseReader.read(step.exists), sourceLocation: sourceLocation)

            let stepId = try #require(step.id, sourceLocation: sourceLocation)
            previousStepId = stepId

            for var ingredient in stepIngredients.ingredients {
                ingredient.stepId = stepId
                appData.insert(&ingredient)
                #expect(try appData.databaseReader.read(ingredient.exists), sourceLocation: sourceLocation)
            }
        }

        #expect(appData.steps(with: recipeId).count == recipeTransfer.stepIngredients.count, sourceLocation: sourceLocation)
    }

    func fetchRecipe(named name: String) throws -> Recipe? {
        let appData = BackAppData.shared
        return try appData.databaseReader.read { db in
            try Recipe.filter(Recipe.Columns.name == name).fetchOne(db)
        }
    }

    func insertExampleRecipe(sourceLocation: SourceLocation = #_sourceLocation) throws -> Recipe {
        try insert(recipeTransfer: Recipe.example, sourceLocation: sourceLocation)
        let recipe = try fetchRecipe(named: Recipe.example.recipe.name)
        return try #require(recipe, sourceLocation: sourceLocation)
    }

    func insertExampleRecipeAndGetId(sourceLocation: SourceLocation = #_sourceLocation) throws -> Int64 {
        let recipe = try insertExampleRecipe(sourceLocation: sourceLocation)
        return try #require(recipe.id, sourceLocation: sourceLocation)
    }

    func insertComplexRecipe(sourceLocation: SourceLocation = #_sourceLocation) throws -> Recipe {
        let transfer = Recipe.complexExample(number: 0)
        try insert(recipeTransfer: transfer, sourceLocation: sourceLocation)
        let recipe = try fetchRecipe(named: transfer.recipe.name)
        return try #require(recipe, sourceLocation: sourceLocation)
    }

    func insertComplexRecipeAndGetId(sourceLocation: SourceLocation = #_sourceLocation) throws -> Int64 {
        let recipe = try insertComplexRecipe(sourceLocation: sourceLocation)
        return try #require(recipe.id, sourceLocation: sourceLocation)
    }

    func insertMultilayerRecipeAndGetId(sourceLocation: SourceLocation = #_sourceLocation) throws -> Int64 {
        let transfer = Recipe.multilayerSubstepExample(number: 0)
        try insert(recipeTransfer: transfer, complex: true, sourceLocation: sourceLocation)
        let recipe = try #require(try fetchRecipe(named: transfer.recipe.name), sourceLocation: sourceLocation)
        return try #require(recipe.id, sourceLocation: sourceLocation)
    }

    @Test
    func updatingExample() throws {
        try insert(recipeTransfer: Recipe.example)

        let appData = BackAppData.shared

        let recipeExample = Recipe.example

        var recipe = try #require(appData.allRecords(of: Recipe.self).first(where: { $0.name == recipeExample.recipe.name }))

        recipe.difficulty = .medium

        appData.update(recipe)

        let recipeId = try #require(recipe.id)
        let updatedRecipe = try #require(appData.record(with: recipeId, of: Recipe.self))
        #expect(updatedRecipe.difficulty == .medium)

        for stepIngredients in recipeExample.stepIngredients {
            try update(stepIngredients: stepIngredients, recipeId: recipeId)
        }
    }

    @Test
    func updatingComplexRecipe() throws {
        try insert(recipeTransfer: Recipe.complexExample(number: 0))

        let appData = BackAppData.shared

        let complexRecipeExample = Recipe.complexExample(number: 0)

        var recipe = try #require(appData.allRecords(of: Recipe.self).first(where: { $0.name == complexRecipeExample.recipe.name }))

        recipe.difficulty = .medium

        appData.update(recipe)

        let recipeId = try #require(recipe.id)
        let updatedRecipe = try #require(appData.record(with: recipeId, of: Recipe.self))
        #expect(updatedRecipe.difficulty == .medium)

        for stepIngredients in complexRecipeExample.stepIngredients {
            try update(stepIngredients: stepIngredients, recipeId: recipeId)
        }
    }


    func update(stepIngredients: (step: Step, ingredients: [Ingredient]), recipeId: Int64, sourceLocation: SourceLocation = #_sourceLocation) throws {

        let appData = BackAppData.shared

        let fetchedStep = try appData.databaseReader.read { db in
            try Step.all().orderedByNumber(with: recipeId).filter( Step.Columns.name == stepIngredients.step.name ).fetchOne(db)
        }

        var step = try #require(fetchedStep, sourceLocation: sourceLocation)

        step.duration = 10000

        appData.update(step)

        let stepId = try #require(step.id, sourceLocation: sourceLocation)
        let updatedStep = try #require(appData.record(with: stepId, of: Step.self), sourceLocation: sourceLocation)
        #expect(updatedStep.duration == 10000, sourceLocation: sourceLocation)

        for ingredient in stepIngredients.ingredients {
            try update(ingredient: ingredient, with: stepId, sourceLocation: sourceLocation)
        }
    }

    func update(ingredient: Ingredient, with stepId: Int64, sourceLocation: SourceLocation = #_sourceLocation) throws {

        let appData = BackAppData.shared

        let fetchedIngredient = try appData.databaseReader.read { db in
            try Ingredient.all().orderedByNumber(with: stepId).fetchOne(db)
        }

        var ingredient = try #require(fetchedIngredient, sourceLocation: sourceLocation)

        ingredient.mass += 1

        appData.update(ingredient)

        let ingredientId = try #require(ingredient.id, sourceLocation: sourceLocation)
        let updatedIngredient = try #require(appData.record(with: ingredientId, of: Ingredient.self), sourceLocation: sourceLocation)
        #expect(updatedIngredient.mass == ingredient.mass, sourceLocation: sourceLocation)
    }


    @Test
    func exportingAndImporting() async throws {
        try insert(recipeTransfer: Recipe.example)
        try insert(recipeTransfer: Recipe.complexExample(number: 0))

        let appData = BackAppData.shared

        let recipes = appData.allRecipes
        let steps = appData.allSteps
        let ingredients = appData.allIngredients

        // the bare test runner has no app sandbox, so the Documents directory may not
        // exist yet; exportRecipesToFile force-tries writing into it and would crash
        try FileManager.default.createDirectory(at: FileManager.default.documentsDirectory, withIntermediateDirectories: true)

        let url = appData.exportAllRecipesToFile()

        try appData.deleteAll(of: Recipe.self)

        let result = await appData.open(url)
        #expect(result == .imported)

        for recipe in recipes {
            #expect(appData.allRecipes.contains(where: { $0.name == recipe.name }))
        }

        for step in steps {
            #expect(appData.allSteps.contains(where: { $0.name == step.name }))
        }

        for ingredient in ingredients {
            #expect(appData.allIngredients.contains(where: { $0.name == ingredient.name }))
        }
    }


    @Test
    func deletingExample() throws {
        try insert(recipeTransfer: Recipe.example)

        let appData = BackAppData.shared

        let recipeExample = Recipe.example

        let fetchedRecipe = try appData.databaseReader.read { db in
            try Recipe.filter(Recipe.Columns.name == recipeExample.recipe.name).fetchOne(db)
        }
        let recipe = try #require(fetchedRecipe)
        let recipeId = try #require(recipe.id)

        let stepIds = try appData.databaseReader.read { db in
            try Step.all().orderedByNumber(with: recipeId).fetchAll(db).compactMap { $0.id }
        }

        appData.delete(recipe)

        #expect(appData.record(with: recipeId, of: Recipe.self) == nil)
        let steps = try appData.databaseReader.read { db in
            try Step.all().orderedByNumber(with: recipeId).fetchAll(db)
        }
        #expect(steps.isEmpty)
        for stepId in stepIds {
            let ingredients = try appData.databaseReader.read { db in
                try Ingredient.all().orderedByNumber(with: stepId).fetchAll(db)
            }
            #expect(ingredients.isEmpty)
        }

    }

    @Test
    func numberOfAllIngredients() throws {
        let recipeId = try insertExampleRecipeAndGetId()
        #expect(BackAppData.shared.numberOfAllIngredients(for: recipeId) == 5)

        let complexId = try insertComplexRecipeAndGetId()
        #expect(BackAppData.shared.numberOfAllIngredients(for: complexId) == 4)
    }

    @Test
    func totalDurationOfRecipe() throws {
        let appData = BackAppData.shared
        let reader = appData.databaseReader

        let recipe = try insertExampleRecipe()
        #expect(recipe.totalDuration(reader: reader) == 20)

        let complex = try insertComplexRecipe()
        #expect(complex.totalDuration(reader: reader) == 31)
    }

    @Test
    func formattedTotalDurationOfRecipe() throws {
        let appData = BackAppData.shared
        let reader = appData.databaseReader

        let recipeExample = try insertExampleRecipe()
        #expect(recipeExample.formattedTotalDuration(reader: reader) == "20 minutes")

        let complexExample = try insertComplexRecipe()
        #expect(complexExample.formattedTotalDuration(reader: reader) == "31 minutes")
    }

    @Test
    func totalFormattedAmountOfRecipe() throws {
        let recipeId = try insertExampleRecipeAndGetId()
        #expect(BackAppData.shared.totalFormattedAmount(for: recipeId) == "245.0 g")

        let complexId = try insertComplexRecipeAndGetId()
        #expect(BackAppData.shared.totalFormattedAmount(for: complexId) == "600.0 g")
    }

    @Test
    func formattedTotalDoughYield() throws {
        let recipeId = try insertExampleRecipeAndGetId()
        #expect(BackAppData.shared.formattedTotalDoughYield(for: recipeId) == "0.91")

        let complexId = try insertComplexRecipeAndGetId()
        #expect(BackAppData.shared.formattedTotalDoughYield(for: complexId) == "0.50")
    }

    @Test
    func recipeText() throws {
        let appData = BackAppData.shared
        let reader = appData.databaseReader

        let recipeExample = try insertExampleRecipe()
        let recipeId = try #require(recipeExample.id)
        // MeasurementFormatting.localeOverride is set to en_US in init,
        // so temperatures are formatted in °F (20°C -> 68°F).
        #expect(appData.text(for: recipeId, roomTemp: 20, scaleFactor: 1, kneadingHeating: 0) == "Sauerteigcracker 1 piece\nMischen \(dateFormatter.string(from: Date()))\n\tVollkornmehl: 50.0 g \n\tAnstellgut TA 200: 120.0 g \n\tOlivenöl: 40.0 g 68°F\n\tSaaten: 30.0 g \n\tSalz: 5.0 g \nBacken \(dateFormatter.string(from: Date().addingTimeInterval(Recipe.example.stepIngredients[0].step.duration)))\n170˚ C\nDone: \(dateFormatter.string(from: Date().addingTimeInterval(TimeInterval(recipeExample.totalDuration(reader: reader) * 60))))")
    }

    @Test
    func movingRecords() async throws {
        let recipeId = try insertExampleRecipeAndGetId()
        try insert(recipeTransfer: Recipe.complexExample(number: 0))
        let appData = BackAppData.shared

        try await appData.moveStep(with: recipeId, from: 1, to: 0)
        #expect(appData.reorderedSteps(for: recipeId).first?.formattedName == "Backen")

        let step = try #require(appData.reorderedSteps(for: recipeId).first(where: { $0.formattedName == "Mischen" }))
        let stepId = try #require(step.id)
        try await appData.moveIngredient(with: stepId, from: 1, to: 2)
        #expect(appData.ingredients(with: stepId)[safe: 1]?.formattedName == "Olivenöl")

        try await appData.moveRecipe(from: 1, to: 0)
        #expect(appData.allRecipes.first?.formattedName == "Komplexes Rezept")
    }

    @Test
    func duplicatingExampleRecipe() throws {
        let appData = BackAppData.shared
        let writer = appData.dbWriter

        let recipeExample = try insertExampleRecipe()
        let recipeId = try #require(recipeExample.id)

        #expect(appData.allRecipes.count == 1)
        #expect(appData.allSteps.count == 2)
        #expect(appData.allIngredients.count == appData.numberOfAllIngredients(for: recipeId))
        recipeExample.duplicate(writer: writer)
        #expect(appData.allRecipes.count == 2)
        #expect(appData.allIngredients.count == appData.numberOfAllIngredients(for: recipeId) * 2)
        #expect(appData.allSteps.count == 4)
    }

    @Test
    func duplicatingComplexRecipe() throws {
        let appData = BackAppData.shared
        let writer = appData.dbWriter

        let recipeExample = try insertComplexRecipe()
        let recipeId = try #require(recipeExample.id)

        #expect(appData.allRecipes.count == 1)
        #expect(appData.allSteps.count == 2)
        #expect(appData.allIngredients.count == appData.numberOfAllIngredients(for: recipeId))
        recipeExample.duplicate(writer: writer)
        #expect(appData.allRecipes.count == 2)
        #expect(appData.allIngredients.count == appData.numberOfAllIngredients(for: recipeId) * 2)
        #expect(appData.allSteps.count == 4)
    }

    /// tests the new query for finding the correct order of steps
    @Test
    func reorderedSteps() throws {
        let appData = BackAppData.shared
        let recipeId = try insertExampleRecipeAndGetId()
        let steps = appData.reorderedSteps(for: recipeId)

        #expect(steps.map(\.formattedName) == ["Mischen", "Backen"])

        let complexId = try insertComplexRecipeAndGetId()
        let complexSteps = appData.reorderedSteps(for: complexId)
        #expect(complexSteps.map(\.formattedName) == ["Sauerteig", "Hauptteig"])

        let multilayerId = try insertMultilayerRecipeAndGetId()
        let multilayerSteps = appData.reorderedSteps(for: multilayerId)
        #expect(multilayerSteps.map(\.formattedName) == ["s1sub2subsub", "s1sub2sub", "s1sub1sub", "s1sub1", "s1sub2", "Schritt", "s2"])
    }

    @Test
    func stepIngredientNumber() throws {
        let appData = BackAppData.shared
        let recipeId = try insertComplexRecipeAndGetId()
        let reader = appData.databaseReader

        let step = try #require(appData.steps(with: recipeId).first)
        #expect(step.ingredientCount(reader: reader) == 2)
        #expect(step.ingredients(reader: reader).count == 2)

        // test if ingredientCount works for the secondStep
        let secondStep = try #require(appData.steps(with: recipeId)[safe: 1])
        #expect(secondStep.ingredientCount(reader: reader) == 2)
        #expect(secondStep.ingredients(reader: reader).count == 2)
    }

    @Test
    func stepsWithIngredientsOrSupersteps() async throws {
        let appData = BackAppData.shared
        let recipeId = try insertMultilayerRecipeAndGetId()
        let step = try #require(appData.steps(with: recipeId).first)
        let stepId = try #require(step.id)
        let possibleSubsteps = appData.stepsWithIngredientsOrSupersteps(in: recipeId, without: stepId)
        #expect(possibleSubsteps.count == 1)

        var substep = try #require(possibleSubsteps.first)
        substep.superStepId = stepId
        // wait for the completion handler so the expectation is guaranteed to run
        // before the test ends
        await withCheckedContinuation { continuation in
            appData.update(substep) { _ in
                #expect(appData.stepsWithIngredientsOrSupersteps(in: recipeId, without: stepId).isEmpty)
                continuation.resume()
            }
        }
    }
}
