// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import Foundation
import Testing
@testable import BackAppCore
@testable import BakingRecipeFoundation
@testable import GRDB

/// Availability-safe async wait helper for unit tests
@inline(__always)
func waitSeconds(_ seconds: UInt64) async {
    if #available(iOS 16.0, *) {
        // Prefer Duration-based API when available
        try? await Task.sleep(for: .seconds(seconds))
    } else {
        // Fallback for older OS versions
        try? await Task.sleep(nanoseconds: seconds * 1_000_000_000)
    }
}

@Suite
struct BackAppCoreTests {
    
    var appData: BackAppData

    // Per-test setup: Swift Testing creates a new instance for each test.
    init() {
        UserDefaults.standard.set(["en"], forKey: "AppleLanguages")
        UserDefaults.standard.set("en_US", forKey: "AppleLocale")
        UserDefaults.standard.synchronize()
        // Nuke the database before each test instance
        self.appData = BackAppData.shared(resetDatabase: true)
    }

    // Helper to reduce duplication in schema tests
    func assertTableSchema(existsName: String, columnsName: String? = nil, expectedColumns: Set<String>) throws {
        // Given an empty database
        let dbQueue = try DatabaseQueue()

        // When we instantiate BackAppData
        _ = try BackAppData(dbQueue)

        // Then the table exists with its columns
        try dbQueue.read { db in
            #expect(try db.tableExists(existsName))
            let columns = try db.columns(in: columnsName ?? existsName)
            let columnNames = Set(columns.map { $0.name })
            #expect(columnNames == expectedColumns)
        }
    }

    @Test
    func testRecipeDatabaseSchema() throws {
        try assertTableSchema(
            existsName: "Recipe",
            expectedColumns: ["id", "name", "info", "isFavorite", "difficulty", "inverted", "times", "date", "imageData", "number"]
        )
    }

    @Test
    func testStepDatabaseSchema() throws {
        try assertTableSchema(
            existsName: "Step",
            expectedColumns: ["id", "name", "duration", "isKneadingStep", "temperature", "notes", "recipeId", "superStepId", "number", "endTemp"]
        )
    }

    @Test
    func testIngredientDatabaseSchema() throws {
        try assertTableSchema(
            existsName: "ingredient",
            columnsName: "Ingredient",
            expectedColumns: ["id", "name", "temperature", "mass", "c", "stepId", "number"]
        )
    }

    @Test
    func testInsertingExample() throws {
        try insert(recipeTransfer: Recipe.example)
    }

    @Test
    func testInsertingComplexRecipe() throws {
        try insert(recipeTransfer: Recipe.complexExample(number: 0))
    }

    @Test
    func testInsertingMultilayerRecipe() throws {
        try insert(recipeTransfer: Recipe.multilayerSubstepExample(number: 0), complex: true)

        let recipeId: Int64 = try appData.databaseReader.read { db in
            let recipe = try Recipe.filter(Recipe.Columns.name == "multilayer").fetchOne(db)
            return recipe!.id!
        }

        //verify that the substeps are correct
        let step = appData.steps(with: recipeId).first
        #expect(appData.sortedSubsteps(for: step!.id!).count == 2)
    }

    func insert(recipeTransfer: RecipeTransferType, complex: Bool = false) throws {
        var recipe = recipeTransfer.recipe
        let appData = BackAppData.shared

        appData.insert(&recipe)
        #expect(try appData.databaseReader.read(recipe.exists))

        var previousStepId: Int64?

        _ = try recipeTransfer.stepIngredients.map {
            var step = $0.step
            step.recipeId = recipe.id!

            //check if there is any superstep id that is not nil. any superstep id is used as a notation to say that the step is suposed to be substep of the previously inserted step. This means the superstepid is not set if it was nil before.
            if !complex, step.superStepId != nil, let previousStepId = previousStepId {
                step.superStepId = previousStepId
            } else if complex, let superStepId = step.superStepId, let superStep = appData.steps(with: step.recipeId).first(where: { $0.number == superStepId }), let newId = superStep.id  { // check only steps of the recipe to improve efficiency and don't missmatch the superstep.
                step.superStepId = newId
            }
            appData.insert(&step)

            #expect(try appData.databaseReader.read(step.exists))

            let stepId = step.id!
            previousStepId = stepId

            for ingredient in $0.ingredients {
                var ingredient = ingredient
                ingredient.stepId = stepId
                appData.insert(&ingredient)
                #expect(try appData.databaseReader.read(ingredient.exists))
            }
        }

        #expect(appData.steps(with: recipe.id!).count == recipeTransfer.stepIngredients.count)
    }

    func fetchRecipe(named name: String) throws -> Recipe? {
        let appData = BackAppData.shared
        return try appData.databaseReader.read { db in
            try Recipe.filter(Recipe.Columns.name == name).fetchOne(db)
        }
    }

    func insertExampleRecipeAndGetId() throws -> Int64 {
        try insert(recipeTransfer: Recipe.example)
        let recipe = try fetchRecipe(named: Recipe.example.recipe.name)
        #expect(recipe != nil)
        return recipe!.id!
    }

    func insertExampleRecipe() throws -> Recipe {
        try insert(recipeTransfer: Recipe.example)
        let recipe = try fetchRecipe(named: Recipe.example.recipe.name)
        #expect(recipe != nil)
        return recipe!
    }

    func insertComplexRecipeAndGetId() throws -> Int64 {
        let transfer = Recipe.complexExample(number: 0)
        try insert(recipeTransfer: transfer)
        let recipe = try fetchRecipe(named: transfer.recipe.name)
        #expect(recipe != nil)
        return recipe!.id!
    }

    func insertComplexRecipe() throws -> Recipe {
        let transfer = Recipe.complexExample(number: 0)
        try insert(recipeTransfer: transfer)
        let recipe = try fetchRecipe(named: transfer.recipe.name)
        #expect(recipe != nil)
        return recipe!
    }

    func insertMultilayerRecipeAndGetId() throws -> Int64 {
        let transfer = Recipe.multilayerSubstepExample(number: 0)
        try insert(recipeTransfer: transfer, complex: true)
        let recipe  = try fetchRecipe(named: transfer.recipe.name)
        #expect(recipe != nil)
        return recipe!.id!
    }

    @Test
    func testUpdatingExample() throws {
        try insert(recipeTransfer: Recipe.example)

        let appData = BackAppData.shared

        let recipeExample = Recipe.example

        var recipe = appData.allRecords(of: Recipe.self).first(where: { $0.name == recipeExample.recipe.name })!

        recipe.difficulty = .medium

        appData.update(recipe)

        #expect(appData.record(with: recipe.id!, of: Recipe.self)!.difficulty == .medium)

        _ = try recipeExample.stepIngredients.map { try update(stepIngredients: $0, recipeId: recipe.id!)}
    }

    @Test
    func testUpdatingComplexRecipe() throws {
        try insert(recipeTransfer: Recipe.complexExample(number: 0))

        let appData = BackAppData.shared

        let complexRecipeExample = Recipe.complexExample(number: 0)

        var recipe = appData.allRecords(of: Recipe.self).first(where: { $0.name == complexRecipeExample.recipe.name })!

        recipe.difficulty = .medium

        appData.update(recipe)

        #expect(appData.record(with: recipe.id!, of: Recipe.self)!.difficulty == .medium)

        _ = try complexRecipeExample.stepIngredients.map { try update(stepIngredients: $0, recipeId: recipe.id!)}
    }


    func update(stepIngredients: (step: Step, ingredients: [Ingredient]), recipeId: Int64) throws {

        let appData = BackAppData.shared

        var step = try appData.databaseReader.read { db in
            try Step.all().orderedByNumber(with: recipeId).filter( Step.Columns.name == stepIngredients.step.name ).fetchOne(db)
        }

        #expect(step != nil)

        step!.duration = 10000

        appData.update(step!)

        #expect(appData.record(with: step!.id!, of: Step.self)!.duration == 10000)

        _ = try stepIngredients.ingredients.map { try update(ingredient: $0, with: step!.id!)}
    }

    func update(ingredient: Ingredient, with stepId: Int64) throws {

        let appData = BackAppData.shared

        var ingredient = try appData.databaseReader.read { db in
            try Ingredient.all().orderedByNumber(with: stepId).fetchOne(db)
        }

        #expect(ingredient != nil)

        ingredient!.mass += 1

        appData.update(ingredient!)
        //XCTAssert(appData.update(ingredient!))

        #expect(appData.record(with: ingredient!.id!, of: Ingredient.self)!.mass == ingredient!.mass)
    }


    @Test
    func testExportingAndImporting() async throws {
        try insert(recipeTransfer: Recipe.example)
        try insert(recipeTransfer: Recipe.complexExample(number: 0))

        let appData = BackAppData.shared

        let recipes = appData.allRecipes
        let steps = appData.allSteps
        let ingredients = appData.allIngredients

        let url = appData.exportAllRecipesToFile()

        try appData.deleteAll(of: Recipe.self)

        appData.open(url)

        await waitSeconds(2)

        for recipe in recipes {
            #expect(appData.allRecipes.first(where: { $0.name == recipe.name }) != nil)
        }

        for step in steps {
            #expect(appData.allSteps.first(where: { $0.name == step.name}) != nil)
        }

        for ingredient in ingredients {
            #expect(appData.allIngredients.first(where: { $0.name == ingredient.name }) != nil)
        }
    }


    @Test
    func testDeletingExample() throws {
        try insert(recipeTransfer: Recipe.example)

        let appData = BackAppData.shared

        let recipeExample = Recipe.example

        let recipe = try appData.databaseReader.read { db in
            try Recipe.filter(Recipe.Columns.name == recipeExample.recipe.name).fetchOne(db)
        }
        #expect(recipe != nil)
        let recipeId = recipe!.id!

        let stepIds = try appData.databaseReader.read { db in
            try Step.all().orderedByNumber(with: recipeId).fetchAll(db).map { $0.id! }
        }

        appData.delete(recipe!)

        #expect(appData.record(with: recipeId, of: Recipe.self) == nil)
        let steps = try appData.databaseReader.read { db in
            try Step.all().orderedByNumber(with: recipeId).fetchAll(db)
        }
        #expect(steps.isEmpty)
        _ = try stepIds.map { stepId in
            let ingredients = try appData.databaseReader.read { db in
                try Ingredient.all().orderedByNumber(with: stepId).fetchAll(db)
            }
            #expect(ingredients.isEmpty)
        }

    }

    @Test
    func testNumberOfAllIngredients() throws {
        let recipeId = try insertExampleRecipeAndGetId()
        #expect(BackAppData.shared.numberOfAllIngredients(for: recipeId) == 5)

        let complexId = try insertComplexRecipeAndGetId()
        #expect(BackAppData.shared.numberOfAllIngredients(for: complexId) == 4)
    }

    @Test
    func testTotalDurationOfRecipe() throws {
        let appData = BackAppData.shared
        let reader = appData.databaseReader

        let recipe = try insertExampleRecipe()
        #expect(recipe.totalDuration(reader: reader) == 20)

        let complex = try insertComplexRecipe()
        #expect(complex.totalDuration(reader: reader) == 31)
    }

    @Test
    func testFormattedTotalDurationOfRecipe() throws {
        let appData = BackAppData.shared
        let reader = appData.databaseReader

        let recipeExample = try insertExampleRecipe()
        #expect(recipeExample.formattedTotalDuration(reader: reader) == "20 minutes")

        let complexExample = try insertComplexRecipe()
        #expect(complexExample.formattedTotalDuration(reader: reader) == "31 minutes")
    }

    @Test
    func testTotalFormattedAmountOfRecipe() throws {
        let recipeId = try insertExampleRecipeAndGetId()
        #expect(BackAppData.shared.totalFormattedAmount(for: recipeId) == "245.0 g")

        let complexId = try insertComplexRecipeAndGetId()
        #expect(BackAppData.shared.totalFormattedAmount(for: complexId) == "600.0 g")
    }

    @Test
    func testFormattedTotalDoughYield() throws {
        let recipeId = try insertExampleRecipeAndGetId()
        #expect(BackAppData.shared.formattedTotalDoughYield(for: recipeId) == "0.91")

        let complexId = try insertComplexRecipeAndGetId()
        #expect(BackAppData.shared.formattedTotalDoughYield(for: complexId) == "0.50")
    }

    @Test
    func testText() throws {
        let appData = BackAppData.shared
        let reader = appData.databaseReader

        let recipeExample = try insertExampleRecipe()
        // With en_US locale set in init, temperatures are formatted in °F (20°C -> 68°F).
        #expect(appData.text(for: recipeExample.id!, roomTemp: 20, scaleFactor: 1, kneadingHeating: 0) == "Sauerteigcracker 1 piece\nMischen \(dateFormatter.string(from: Date()))\n\tVollkornmehl: 50.0 g \n\tAnstellgut TA 200: 120.0 g \n\tOlivenöl: 40.0 g 68°F\n\tSaaten: 30.0 g \n\tSalz: 5.0 g \nBacken \(dateFormatter.string(from: Date().addingTimeInterval(Recipe.example.stepIngredients[0].step.duration)))\n170˚ C\nDone: \(dateFormatter.string(from: Date().addingTimeInterval(TimeInterval(recipeExample.totalDuration(reader: reader) * 60))))")
    }

    @Test
    func testMovingRecords() async throws {
        let recipeId = try insertExampleRecipeAndGetId()
        try insert(recipeTransfer: Recipe.complexExample(number: 0))
        let appData = BackAppData.shared

        appData.moveStep(with: recipeId, from: 1, to: 0)
        await waitSeconds(1)
        #expect(appData.reorderedSteps(for: recipeId).first!.formattedName == "Backen")

        let stepId = appData.reorderedSteps(for: recipeId).first(where: { $0.formattedName == "Mischen"})!.id!
        appData.moveIngredient(with: stepId, from: 1, to: 2)
        await waitSeconds(1)
        #expect(appData.ingredients(with: stepId)[1].formattedName == "Olivenöl")

        appData.moveRecipe(from: 1, to: 0)
        await waitSeconds(1)
        #expect(appData.allRecipes.first!.formattedName == "Komplexes Rezept")
    }

    @Test
    func testDuplicatingExampleRecipe() throws {
        let appData = BackAppData.shared
        let writer = appData.dbWriter

        let recipeExample = try insertExampleRecipe()

        #expect(appData.allRecipes.count == 1)
        #expect(appData.allSteps.count == 2)
        #expect(appData.allIngredients.count == appData.numberOfAllIngredients(for: recipeExample.id!))
        recipeExample.duplicate(writer: writer)
        #expect(appData.allRecipes.count == 2)
        #expect(appData.allIngredients.count == appData.numberOfAllIngredients(for: recipeExample.id!) * 2)
        #expect(appData.allSteps.count == 4)
    }

    @Test
    func testDuplicationgComplexRecipe() throws {
        let appData = BackAppData.shared
        let writer = appData.dbWriter

        let recipeExample = try insertComplexRecipe()
        #expect(appData.allRecipes.count == 1)
        #expect(appData.allSteps.count == 2)
        #expect(appData.allIngredients.count == appData.numberOfAllIngredients(for: recipeExample.id!))
        recipeExample.duplicate(writer: writer)
        #expect(appData.allRecipes.count == 2)
        #expect(appData.allIngredients.count == appData.numberOfAllIngredients(for: recipeExample.id!) * 2)
        #expect(appData.allSteps.count == 4)
    }

    /// tests the new query for finding the correct order of steps
    @Test
    func testReorderedSteps() throws {
        let appData = BackAppData.shared
        let recipeId = try insertExampleRecipeAndGetId()
        let steps = appData.reorderedSteps(for: recipeId)

        #expect("\(steps.map { $0.formattedName })" == "[\"Mischen\", \"Backen\"]")

        let complexId = try insertComplexRecipeAndGetId()
        let complexSteps = appData.reorderedSteps(for: complexId)
        #expect("\(complexSteps.map { $0.formattedName})" == "[\"Sauerteig\", \"Hauptteig\"]")

        let multilayerId = try insertMultilayerRecipeAndGetId()
        let multilayerSteps = appData.reorderedSteps(for: multilayerId)
        #expect("\(multilayerSteps.map {$0.formattedName})" == "[\"s1sub2subsub\", \"s1sub2sub\", \"s1sub1sub\", \"s1sub1\", \"s1sub2\", \"Schritt\", \"s2\"]")
    }

    @Test
    func testStepIngredientNumber() throws {
        let appData = BackAppData.shared
        let recipeId = try insertComplexRecipeAndGetId()
        let step = appData.steps(with: recipeId).first
        let reader = appData.databaseReader
        #expect(step?.ingredientCount(reader: reader) == 2)
        #expect(step?.ingredients(reader: reader).count == 2)
        #expect(step?.ingredients(reader: reader).count == step?.ingredientCount(reader: reader))

        // test if ingredientCount works for the secondStep
        let secondStep = appData.steps(with: recipeId)[safe: 1]
        #expect(secondStep?.ingredientCount(reader: reader) == 2)
        #expect(secondStep?.ingredients(reader: reader).count == 2)
        #expect(secondStep?.ingredients(reader: reader).count == secondStep?.ingredientCount(reader: reader))
    }

    @Test
    func testStepsWithIngredientsOrSupersteps() throws {
        let appData = BackAppData.shared
        let recipeId = try insertMultilayerRecipeAndGetId()
        let step = appData.steps(with: recipeId).first
        #expect(step?.id != nil)
        let possibleSubsteps = appData.stepsWithIngredientsOrSupersteps(in: recipeId, without: step!.id!)
        #expect(possibleSubsteps.count == 1)

        var substep = possibleSubsteps.first!
        substep.superStepId = step!.id
        appData.update(substep) { _ in
            #expect(appData.stepsWithIngredientsOrSupersteps(in: recipeId, without: step!.id!).count == 0)
        }
    }
}

