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
            XCTAssertEqual(columnNames, ["id", "name", "duration", "temperature", "notes", "recipeId", "superStepId", "number"])
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
        let appData = BackAppData.shared
        
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
    
    
    func update(stepIngredients: (step: Step, ingredients: [Ingredient]), recipeId: Int64) throws {
        
        let appData = BackAppData.shared
        
        var step = try appData.databaseReader.read { db in
            try Step.all().filter(by: recipeId).filter( Step.Columns.name == stepIngredients.step.name ).fetchOne(db)
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
            try Ingredient.all().filter(by: stepId).fetchOne(db)
        }
        
        XCTAssert(ingredient != nil)
        
        ingredient!.mass += 1
        
        appData.save(&ingredient!)
        //XCTAssert(appData.update(ingredient!))
        
        XCTAssert(appData.record(with: ingredient!.id!, of: Ingredient.self)!.mass == ingredient!.mass)
    }

    
    func testExportingAndImporting() throws{
        try self.testInsertingExample()
        
        let appData = BackAppData.shared
        
        let recipes = appData.allRecipes
        let steps = appData.allSteps
        let ingredients = appData.allIngredients
        
        let url = appData.exportAllRecipesToFile()
        
        try appData.deleteAll(of: Recipe.self)
        
        appData.open(url)
        
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
            try Step.all().filter(by: recipeId).fetchAll(db).map { $0.id! }
        }
        
        XCTAssert(appData.delete(recipe!))
        
        XCTAssertFalse(appData.record(with: recipeId, of: Recipe.self) != nil)
        let steps = try appData.databaseReader.read { db in
            try Step.all().filter(by: recipeId).fetchAll(db)
        }
        XCTAssertTrue(steps.isEmpty)
        _ = try stepIds.map { stepId in
            let ingredients = try appData.databaseReader.read { db in
                try Ingredient.all().filter(by: stepId).fetchAll(db)
            }
            XCTAssertTrue(ingredients.isEmpty)
        }
        
    }
    
    func testNumberOfAllIngredients() throws {
        try testInsertingExample()
        
        let appData = BackAppData.shared
        
        let recipeExample = Recipe.example
        
        let recipe = try appData.databaseReader.read { db in
            try Recipe.filter(Recipe.Columns.name == recipeExample.recipe.name).fetchOne(db)
        }
        XCTAssert(recipe != nil)
        let recipeId = recipe!.id!
        
        
        
        XCTAssert(appData.numberOfAllIngredients(for: recipeId) == 5)

    }
    
    static var allTests = [
        ("testRecipeDatabaseSchema", testRecipeDatabaseSchema(BackAppCoreTests())),
        ("testStepDatabaseSchema", testStepDatabaseSchema(BackAppCoreTests())),
        ("testIngredientDatabaseSchema",testIngredientDatabaseSchema(BackAppCoreTests())),
        ("testInsertingExample", testInsertingExample(BackAppCoreTests())),
        ("testExportingAndImporting", testExportingAndImporting(BackAppCoreTests())),
        ("testUpdatingExample", testUpdatingExample(BackAppCoreTests())),
        ("testDeletingExample", testDeletingExample(BackAppCoreTests())),
    ]
}
