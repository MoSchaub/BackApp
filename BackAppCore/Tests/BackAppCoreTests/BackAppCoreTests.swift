import XCTest
@testable import BackAppCore
@testable import BakingRecipeFoundation
@testable import GRDB

final class BackAppCoreTests: XCTestCase {
    
    override func setUp() {
        let appData = BackAppData.shared
        try! appData.deleteAll(of: Recipe.self)
        
    }
    
    func testRecipeDatabaseSchema() throws {
        // Given an empty database
        let dbQueue = DatabaseQueue()
        
        // When we instantiate an BackAppData
        _ = try BackAppData(dbQueue)
        
        // Then the recipe table exists with its columns
        try dbQueue.read { db in
            try XCTAssert(db.tableExists("Recipe"))
            let columns = try db.columns(in: "Recipe")
            let columnNames = Set(columns.map { $0.name })
            XCTAssertEqual(columnNames, ["id", "name", "info", "isFavorite", "difficulty", "inverted", "times", "date", "imageData", "number"])
        }
    }
    
    func testStepDatabaseSchema() throws {
        // Given an empty database
        let dbQueue = DatabaseQueue()
        
        // When we instantiate an BackAppData
        _ = try BackAppData(dbQueue)
        
        // Then the step table exists with its columns
        try dbQueue.read { db in
            try XCTAssert(db.tableExists("Step"))
            let columns = try db.columns(in: "Step")
            let columnNames = Set(columns.map { $0.name })
            XCTAssertEqual(columnNames, ["id", "name", "duration", "isKneadingStep", "temperature", "notes", "recipeId", "superStepId", "number", "endTemp"])
        }
    }
    
    func testIngredientDatabaseSchema() throws {
        // Given an empty database
        let dbQueue = DatabaseQueue()
        
        // When we instantiate an BackAppData
        _ = try BackAppData(dbQueue)
        
        // Then the ingredient table exists with its columns
        try dbQueue.read { db in
            try XCTAssert(db.tableExists("ingredient"))
            let columns = try db.columns(in: "Ingredient")
            let columnNames = Set(columns.map { $0.name })
            XCTAssertEqual(columnNames, ["id", "name", "temperature", "mass", "c", "stepId", "number"])
        }
    }
    
    
    
    func testInsertingExample() throws {
        let recipeExample = Recipe.example
        var recipe = recipeExample.recipe
        let appData = BackAppData.shared()

        appData.save(&recipe)
        try XCTAssertTrue(appData.databaseReader.read(recipe.exists))

        let id = recipe.id!

        let stepIngredients = recipeExample.stepIngredients

        _ = try stepIngredients.map {
            var step = $0.step
            step.recipeId = id
            appData.save(&step)
            try XCTAssertTrue(appData.databaseReader.read(step.exists))

            let stepId = step.id!

            for ingredient in $0.ingredients {
                var ingredient = ingredient
                ingredient.stepId = stepId
                appData.save(&ingredient)
                try XCTAssert(appData.databaseReader.read(ingredient.exists))
            }
        }
    }
    
    func testInsertingComplexRecipe() throws {
        let complexRecipe = Recipe.complexExample(number: 0)
        var recipe = complexRecipe.recipe
        let appData = BackAppData.shared
        
        appData.save(&recipe)
        try XCTAssert(appData.databaseReader.read(recipe.exists))
        
        let recipeId = recipe.id!
        
        let stepIngredients = complexRecipe.stepIngredients
        
        var previousStepId: Int64?
        
        _ = try stepIngredients.map {
            var step = $0.step
            step.recipeId = recipeId
            
            if step.superStepId != nil, let previousStepId = previousStepId {
                step.superStepId = previousStepId
            }
            appData.save(&step)
            
            try XCTAssertTrue(appData.databaseReader.read(step.exists))
            
            let stepId = step.id!
            previousStepId = stepId
            
            for ingredient in $0.ingredients {
                var ingredient = ingredient
                ingredient.stepId = stepId
                appData.save(&ingredient)
                try XCTAssert(appData.databaseReader.read(ingredient.exists))
            }
        }
    }
    
    func insertExampleRecipeAndGetId() throws -> Int64 {
        try testInsertingExample()
        
        let appData = BackAppData.shared
        
        let recipeExample = Recipe.example
        
        let recipe = try appData.databaseReader.read { db in
            try Recipe.filter(Recipe.Columns.name == recipeExample.recipe.name).fetchOne(db)
        }
        XCTAssert(recipe != nil)
        return recipe!.id!
    }
    
    func insertComplexRecipeAndGetId() throws -> Int64 {
        try testInsertingComplexRecipe()
        
        let appData = BackAppData.shared
        
        let complexRecipeExample = Recipe.complexExample(number: 0)
        
        let recipe = try appData.databaseReader.read { db in
            try Recipe.filter(Recipe.Columns.name == complexRecipeExample.recipe.name).fetchOne(db)
        }
        XCTAssert(recipe != nil)
        return recipe!.id!
    }
    
    func testUpdatingExample() throws {
        try testInsertingExample()
        
        let appData = BackAppData.shared
        
        let recipeExample = Recipe.example
        
        var recipe = appData.allRecords(of: Recipe.self).first(where: { $0.name == recipeExample.recipe.name })!
        
        recipe.difficulty = .medium
        
        appData.save(&recipe)
        
        XCTAssert(appData.record(with: recipe.id!, of: Recipe.self)!.difficulty == .medium)
        
        _ = try recipeExample.stepIngredients.map { try update(stepIngredients: $0, recipeId: recipe.id!)}
    }
    
    func testUpdatingComplexRecipe() throws {
        try testInsertingComplexRecipe()
        
        let appData = BackAppData.shared
        
        let complexRecipeExample = Recipe.complexExample(number: 0)
        
        var recipe = appData.allRecords(of: Recipe.self).first(where: { $0.name == complexRecipeExample.recipe.name })!
        
        recipe.difficulty = .medium
        
        appData.save(&recipe)
        
        XCTAssert(appData.record(with: recipe.id!, of: Recipe.self)!.difficulty == .medium)
        
        _ = try complexRecipeExample.stepIngredients.map { try update(stepIngredients: $0, recipeId: recipe.id!)}
    }
    
    
    func update(stepIngredients: (step: Step, ingredients: [Ingredient]), recipeId: Int64) throws {
        
        let appData = BackAppData.shared
        
        var step = try appData.databaseReader.read { db in
            try Step.all().orderedByNumber(with: recipeId).filter( Step.Columns.name == stepIngredients.step.name ).fetchOne(db)
        }
        
        XCTAssert(step != nil)
        
        step!.duration = 10000
        
        appData.save(&step!)
        
        XCTAssert(appData.record(with: step!.id!, of: Step.self)!.duration == 10000)
        
        _ = try stepIngredients.ingredients.map { try update(ingredient: $0, with: step!.id!)}
    }
    
    func update(ingredient: Ingredient, with stepId: Int64) throws {
        
        let appData = BackAppData.shared
        
        var ingredient = try appData.databaseReader.read { db in
            try Ingredient.all().orderedByNumber(with: stepId).fetchOne(db)
        }
        
        XCTAssert(ingredient != nil)
        
        ingredient!.mass += 1
        
        appData.save(&ingredient!)
        //XCTAssert(appData.update(ingredient!))
        
        XCTAssert(appData.record(with: ingredient!.id!, of: Ingredient.self)!.mass == ingredient!.mass)
    }

    
    func testExportingAndImporting() throws{
        try self.testInsertingExample()
        try self.testInsertingComplexRecipe()
        
        let appData = BackAppData.shared
        
        let recipes = appData.allRecipes
        let steps = appData.allSteps
        let ingredients = appData.allIngredients
        
        let url = appData.exportAllRecipesToFile()
        
        try appData.deleteAll(of: Recipe.self)
        
        appData.open(url)
        
        sleep(1)
        
        for recipe in recipes {
            XCTAssert(appData.allRecipes.first(where: { $0.name == recipe.name }) != nil)
        }
        
        for step in steps {
            XCTAssert(appData.allSteps.first(where: { $0.name == step.name}) != nil)
        }
        
        for ingredient in ingredients {
            XCTAssert(appData.allIngredients.first(where: { $0.name == ingredient.name }) != nil)
        }
    }


    func testDeletingExample() throws {
        try testInsertingExample()
        
        let appData = BackAppData.shared
        
        let recipeExample = Recipe.example
        
        let recipe = try appData.databaseReader.read { db in
            try Recipe.filter(Recipe.Columns.name == recipeExample.recipe.name).fetchOne(db)
        }
        XCTAssert(recipe != nil)
        let recipeId = recipe!.id!
        
        let stepIds = try appData.databaseReader.read { db in
            try Step.all().orderedByNumber(with: recipeId).fetchAll(db).map { $0.id! }
        }
        
        XCTAssert(appData.delete(recipe!))
        
        XCTAssertFalse(appData.record(with: recipeId, of: Recipe.self) != nil)
        let steps = try appData.databaseReader.read { db in
            try Step.all().orderedByNumber(with: recipeId).fetchAll(db)
        }
        XCTAssertTrue(steps.isEmpty)
        _ = try stepIds.map { stepId in
            let ingredients = try appData.databaseReader.read { db in
                try Ingredient.all().orderedByNumber(with: stepId).fetchAll(db)
            }
            XCTAssertTrue(ingredients.isEmpty)
        }
        
    }
    
    func testNumberOfAllIngredients() throws {
        let recipeId = try insertExampleRecipeAndGetId()
        XCTAssert(BackAppData.shared.numberOfAllIngredients(for: recipeId) == 5)
        
        let complexId = try insertComplexRecipeAndGetId()
        XCTAssert(BackAppData.shared.numberOfAllIngredients(for: complexId) == 4)
    }
    
    func testTotalDurationOfRecipe() throws {
        
        let recipeId = try insertExampleRecipeAndGetId()
        XCTAssert(BackAppData.shared.totalDuration(for: recipeId) == 20)
        
        let complexId = try insertComplexRecipeAndGetId()
        XCTAssert(BackAppData.shared.totalDuration(for: complexId) == 31)
    }
    
    func testFormattedTotalDurationOfRecipe() throws {
        
        let recipeId = try insertExampleRecipeAndGetId()
        XCTAssert(BackAppData.shared.formattedTotalDuration(for: recipeId) == "20 minutes")
        
        let complexId = try insertComplexRecipeAndGetId()
        XCTAssert(BackAppData.shared.formattedTotalDuration(for: complexId) == "31 minutes")
    }
    
    func testTotalFormattedAmountOfRecipe() throws {
        let recipeId = try insertExampleRecipeAndGetId()
        XCTAssert(BackAppData.shared.totalFormattedAmount(for: recipeId) == "245.0 g")
        
        let complexId = try insertComplexRecipeAndGetId()
        XCTAssert(BackAppData.shared.totalFormattedAmount(for: complexId) == "600.0 g")
    }
    
    func testFormattedTotalDoughYield() throws {
        
        let recipeId = try insertExampleRecipeAndGetId()
        XCTAssert(BackAppData.shared.formattedTotalDoughYield(for: recipeId) == "0.91")
        
        let complexId = try insertComplexRecipeAndGetId()
        XCTAssert(BackAppData.shared.formattedTotalDoughYield(for: complexId) == "0.50")
    }
    
    func testText() throws {
        let recipeId = try insertExampleRecipeAndGetId()
        XCTAssert(BackAppData.shared.text(for: recipeId, roomTemp: 20, scaleFactor: 1, kneadingHeating: 0) == "Sauerteigcracker 1 piece\nMischen \(dateFormatter.string(from: Date()))\n\tVollkornmehl: 50.0 g \n\tAnstellgut TA 200: 120.0 g \n\tOlivenöl: 40.0 g 20.0° C\n\tSaaten: 30.0 g \n\tSalz: 5.0 g \nBacken \(dateFormatter.string(from: Date().addingTimeInterval(Recipe.example.stepIngredients[0].step.duration)))\n170˚ C\nFertig: \(dateFormatter.string(from: Date().addingTimeInterval(TimeInterval(BackAppData.shared.totalDuration(for: recipeId) * 60))))")
    }
    
    func testMovingRecords() throws {
        let recipeId = try insertExampleRecipeAndGetId()
        try testInsertingComplexRecipe()
        let appData = BackAppData.shared
        
        appData.moveStep(with: recipeId, from: 1, to: 0)
        sleep(1)
        XCTAssert(appData.reorderedSteps(for: recipeId).first!.formattedName == "Backen")
        
        let stepId = appData.reorderedSteps(for: recipeId).first(where: { $0.formattedName == "Mischen"})!.id!
        appData.moveIngredient(with: stepId, from: 1, to: 2)
        sleep(1)
        XCTAssert(appData.ingredients(with: stepId)[1].formattedName == "Olivenöl")
        
        appData.moveRecipe(from: 1, to: 0)
        sleep(1)
        XCTAssert(appData.allRecipes.first!.formattedName == "Komplexes Rezept")
    }
    
    static var allTests = [
        ("testRecipeDatabaseSchema", testRecipeDatabaseSchema(BackAppCoreTests())),
        ("testStepDatabaseSchema", testStepDatabaseSchema(BackAppCoreTests())),
        ("testIngredientDatabaseSchema",testIngredientDatabaseSchema(BackAppCoreTests())),
        ("testInsertingExample", testInsertingExample(BackAppCoreTests())),
        ("testExportingAndImporting", testExportingAndImporting(BackAppCoreTests())),
        ("testUpdatingExample", testUpdatingExample(BackAppCoreTests())),
        ("testDeletingExample", testDeletingExample(BackAppCoreTests())),
        ("testNumberOfAllIngredients",testNumberOfAllIngredients(BackAppCoreTests())),
        ("testTotalDurationOfRecipe", testTotalDurationOfRecipe(BackAppCoreTests()))
    ]
}
