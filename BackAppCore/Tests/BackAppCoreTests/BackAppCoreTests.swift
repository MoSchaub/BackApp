import XCTest
@testable import BackAppCore
@testable import BakingRecipeFoundation
@testable import GRDB

final class BackAppCoreTests: XCTestCase {

    var appData: BackAppData!
    
    override func setUp() {
        //nuke the database after every test
        appData = BackAppData.shared
        try! appData.deleteAll(of: Recipe.self)
    }
    
    func testRecipeDatabaseSchema() throws {
        // Given an empty database
        let dbQueue = try! DatabaseQueue()
        
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
        let dbQueue = try! DatabaseQueue()
        
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
        let dbQueue = try! DatabaseQueue()
        
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
        try insert(recipeTransfer: Recipe.example)
    }
    
    func testInsertingComplexRecipe() throws {
        try insert(recipeTransfer: Recipe.complexExample(number: 0))
    }

    func testInsertingMultilayerRecipe() throws {
        try insert(recipeTransfer: Recipe.multilayerSubstepExample(number: 0), complex: true)

        let recipeId: Int64 = try appData.databaseReader.read { db in
            let recipe = try Recipe.filter(Recipe.Columns.name == "multilayer").fetchOne(db)
            return recipe!.id!
        }

        //verify that the substeps are correct
        let step = appData.steps(with: recipeId).first
        XCTAssertEqual(appData.sortedSubsteps(for: step!.id!).count, 2)
    }

    func insert(recipeTransfer: RecipeTransferType, complex: Bool = false) throws {
        var recipe = recipeTransfer.recipe
        let appData = BackAppData.shared

        appData.insert(&recipe)
        try XCTAssert(appData.databaseReader.read(recipe.exists))

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

            try XCTAssertTrue(appData.databaseReader.read(step.exists))

            let stepId = step.id!
            previousStepId = stepId

            for ingredient in $0.ingredients {
                var ingredient = ingredient
                ingredient.stepId = stepId
                appData.insert(&ingredient)
                try XCTAssert(appData.databaseReader.read(ingredient.exists))
            }
        }

        XCTAssertEqual(appData.steps(with: recipe.id!).count, recipeTransfer.stepIngredients.count)
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

    func insertExampleRecipe() throws -> Recipe {
        try testInsertingExample()

        let appData = BackAppData.shared

        let recipeExample = Recipe.example

        let recipe = try appData.databaseReader.read { db in
            try Recipe.filter(Recipe.Columns.name == recipeExample.recipe.name).fetchOne(db)
        }
        XCTAssert(recipe != nil)
        return recipe!
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

    func insertComplexRecipe() throws -> Recipe {
        try testInsertingComplexRecipe()

        let appData = BackAppData.shared

        let complexRecipeExample = Recipe.complexExample(number: 0)

        let recipe = try appData.databaseReader.read { db in
            try Recipe.filter(Recipe.Columns.name == complexRecipeExample.recipe.name).fetchOne(db)
        }
        XCTAssert(recipe != nil)
        return recipe!
    }

    func insertMultilayerRecipeAndGetId() throws -> Int64 {
        try testInsertingMultilayerRecipe()

        let appData = BackAppData.shared

        let multilayerRecipeExample = Recipe.multilayerSubstepExample(number: 0)

        //identify the recipe by name is fine cause there is only one recipe in the database
        let recipe  = try appData.databaseReader.read { db in
            try Recipe.filter(Recipe.Columns.name == multilayerRecipeExample.recipe.name).fetchOne(db)
        }
        XCTAssert(recipe != nil) // check wether the insert worked
        return recipe!.id!
    }
    
    func testUpdatingExample() throws {
        try testInsertingExample()
        
        let appData = BackAppData.shared
        
        let recipeExample = Recipe.example
        
        var recipe = appData.allRecords(of: Recipe.self).first(where: { $0.name == recipeExample.recipe.name })!
        
        recipe.difficulty = .medium
        
        appData.update(recipe)
        
        XCTAssert(appData.record(with: recipe.id!, of: Recipe.self)!.difficulty == .medium)
        
        _ = try recipeExample.stepIngredients.map { try update(stepIngredients: $0, recipeId: recipe.id!)}
    }
    
    func testUpdatingComplexRecipe() throws {
        try testInsertingComplexRecipe()
        
        let appData = BackAppData.shared
        
        let complexRecipeExample = Recipe.complexExample(number: 0)
        
        var recipe = appData.allRecords(of: Recipe.self).first(where: { $0.name == complexRecipeExample.recipe.name })!
        
        recipe.difficulty = .medium
        
        appData.update(recipe)
        
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
        
        appData.update(step!)

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
        
        appData.update(ingredient!)
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
        
        appData.delete(recipe!)
        
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
        let appData = BackAppData.shared
        let reader = appData.databaseReader

        let recipe = try insertExampleRecipe()
        XCTAssert(recipe.totalDuration(reader: reader) == 20)
        
        let complex = try insertComplexRecipe()
        XCTAssert(complex.totalDuration(reader: reader) == 31)
    }
    
    func testFormattedTotalDurationOfRecipe() throws {
        let appData = BackAppData.shared
        let reader = appData.databaseReader
        
        let recipeExample = try insertExampleRecipe()
        XCTAssert(recipeExample.formattedTotalDuration(reader: reader) == "20 minutes")
        
        let complexExample = try insertComplexRecipe()
        XCTAssert(complexExample.formattedTotalDuration(reader: reader) == "31 minutes")
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
        let appData = BackAppData.shared
        let reader = appData.databaseReader

        let recipeExample = try insertExampleRecipe()
        XCTAssertEqual(appData.text(for: recipeExample.id!, roomTemp: 20, scaleFactor: 1, kneadingHeating: 0), "Sauerteigcracker 1 piece\nMischen \(dateFormatter.string(from: Date()))\n\tVollkornmehl: 50.0 g \n\tAnstellgut TA 200: 120.0 g \n\tOlivenöl: 40.0 g 20°C\n\tSaaten: 30.0 g \n\tSalz: 5.0 g \nBacken \(dateFormatter.string(from: Date().addingTimeInterval(Recipe.example.stepIngredients[0].step.duration)))\n170˚ C\nDone: \(dateFormatter.string(from: Date().addingTimeInterval(TimeInterval(recipeExample.totalDuration(reader: reader) * 60))))")
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

    func testDuplicatingExampleRecipe() throws {
        let writer = appData.dbWriter

        let recipeExample = try insertExampleRecipe()

        XCTAssertEqual(appData.allRecipes.count, 1)
        XCTAssertEqual(appData.allSteps.count, 2)
        XCTAssertEqual(appData.allIngredients.count, appData.numberOfAllIngredients(for: recipeExample.id!))
        recipeExample.duplicate(writer: writer)
        XCTAssertEqual(appData.allRecipes.count, 2)
        XCTAssertEqual(appData.allIngredients.count, appData.numberOfAllIngredients(for: recipeExample.id!) * 2)
        XCTAssertEqual(appData.allSteps.count, 4)
    }

    func testDuplicationgComplexRecipe() throws {
        let writer = appData.dbWriter

        let recipeExample = try insertComplexRecipe()
        XCTAssertEqual(appData.allRecipes.count, 1)
        XCTAssertEqual(appData.allSteps.count, 2)
        XCTAssertEqual(appData.allIngredients.count, appData.numberOfAllIngredients(for: recipeExample.id!))
        recipeExample.duplicate(writer: writer)
        XCTAssertEqual(appData.allRecipes.count, 2)
        XCTAssertEqual(appData.allIngredients.count, appData.numberOfAllIngredients(for: recipeExample.id!) * 2)
        XCTAssertEqual(appData.allSteps.count, 4)

    }

    ///tests the new query for finding the correct order of steps
    func testReorderedSteps() throws {
        let recipeId = try insertExampleRecipeAndGetId()
        let steps = appData.reorderedSteps(for: recipeId)

        XCTAssertEqual("\(steps.map { $0.formattedName })", "[\"Mischen\", \"Backen\"]")

        let complexId = try insertComplexRecipeAndGetId()
        let complexSteps = appData.reorderedSteps(for: complexId)
        XCTAssertEqual("\(complexSteps.map { $0.formattedName})", "[\"Sauerteig\", \"Hauptteig\"]")

        let multilayerId = try insertMultilayerRecipeAndGetId()
        let multilayerSteps = appData.reorderedSteps(for: multilayerId)
        XCTAssertEqual("\(multilayerSteps.map {$0.formattedName})", "[\"s1sub2subsub\", \"s1sub2sub\", \"s1sub1sub\", \"s1sub1\", \"s1sub2\", \"Schritt\", \"s2\"]")
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
