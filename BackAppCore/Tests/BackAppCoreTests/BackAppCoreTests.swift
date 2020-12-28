import XCTest
@testable import BackAppCore
@testable import BakingRecipeFoundation

final class BackAppCoreTests: XCTestCase {
    
    func testInsertingExample() {
        let recipeExample = Recipe.example
        var recipe = recipeExample.recipe
        
        let appData = BackAppData(debug: true)
        
        
        recipe.id = appData.newId(for: Recipe.self)
        
        XCTAssertTrue(appData.insert(recipe))
        
        XCTAssertTrue(appData.object(with: recipe.id, of: Recipe.self) != nil)
        
        let stepsIngredients = recipeExample.stepIngredients
        
        _ = stepsIngredients.map { insert(stepIngredients: $0, recipeId: recipe.id)}
        
        return 
    }
    
    func insert(stepIngredients: (step: Step, ingredients: [Ingredient]), recipeId: Int) {

        let appData = BackAppData()

        var step = stepIngredients.step
        step.recipeId = recipeId

        step.id = appData.newId(for: Step.self)

        XCTAssertTrue(appData.insert(step))

        XCTAssertTrue(appData.object(with: step.id, of: Step.self) != nil)
        XCTAssertTrue(appData.object(with: step.id, of: Step.self)! == step)

        _ = stepIngredients.ingredients.map { insert(ingredient: $0, with: step.id) }
    }
    
    func insert(ingredient: Ingredient, with stepId: Int) {
        let appData = BackAppData()

        var ingredient = ingredient

        ingredient.id = appData.newId(for: Ingredient.self)
        ingredient.stepId = stepId

        XCTAssert(appData.insert(ingredient))
        
        XCTAssert(appData.object(with: ingredient.id, of: Ingredient.self) != nil)
        XCTAssert(appData.object(with: ingredient.id, of: Ingredient.self)! == ingredient)
        return
    }
    
    func testExportingAndImporting() {
        
        var appData = BackAppData()
        
        self.testInsertingExample()
        
        let recipes = appData.allRecipes
        let steps = appData.allSteps
        let ingredients = appData.allIngredients
        
        let url = appData.exportAllRecipesToFile()
        
        appData = BackAppData(debug: true)
        
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
    
    func testUpdatingExample() {
        testInsertingExample()
        
        let appData = BackAppData()
        
        let recipeExample = Recipe.example
        
        var recipe = appData.allRecipes.first(where: { $0.name == recipeExample.recipe.name })
        
        XCTAssert(recipe != nil)
    
        recipe!.difficulty = .medium
        
        XCTAssert(appData.update(recipe!))
        
        XCTAssert(appData.object(with: recipe!.id, of: Recipe.self)!.difficulty == .medium)
        
        _ = recipeExample.stepIngredients.map { update(stepIngredients: $0, recipeId: recipe!.id)}
    }
    
    func update(stepIngredients: (step: Step, ingredients: [Ingredient]), recipeId: Int) {
        
        let appData = BackAppData()
        
        var step = appData.steps(with: recipeId).first(where: { $0.name == stepIngredients.step.name })
        
        XCTAssert(step != nil)
        
        step!.duration = 10000
        
        XCTAssert(appData.update(step!))
        
        XCTAssert(appData.object(with: step!.id, of: Step.self)!.duration == 10000)
        
        _ = stepIngredients.ingredients.map { update(ingredient: $0, with: step!.id)}
    }
    
    func update(ingredient: Ingredient, with stepId: Int) {
        
        let appData = BackAppData()
        
        var ingredient = appData.ingredients(with: stepId).first(where: { $0.name == ingredient.name })
        
        ingredient?.mass += 1
        
        XCTAssert(appData.update(ingredient!))
        
        XCTAssert(appData.object(with: ingredient!.id, of: Ingredient.self)!.mass == ingredient!.mass)
    }
    
    func testDeletingExample() {
        testInsertingExample()
        
        let appData = BackAppData()
        
        let recipeExample = Recipe.example
        
        let recipe = appData.allRecipes.first(where: { $0.name == recipeExample.recipe.name })
        let recipeId = recipe!.id
        
        XCTAssert(recipe != nil)
        
        let stepIds = appData.steps(with: recipeId).map { $0.id }
        
        XCTAssert(appData.delete(recipe!))
        
        XCTAssertFalse(appData.object(with: recipeId, of: Recipe.self) != nil)
        XCTAssertTrue(appData.steps(with: recipeId).isEmpty)
        _ = stepIds.map {
            XCTAssertTrue(appData.ingredients(with: $0).isEmpty)
        }
        
    }
    
    static var allTests = [
        ("testInsertingExample", testInsertingExample(BackAppCoreTests())),
        ("testExportingAndImporting", testExportingAndImporting(BackAppCoreTests())),
        ("testUpdatingExample", testUpdatingExample(BackAppCoreTests())),
        ("testDeletingExample", testDeletingExample(BackAppCoreTests())),
    ]
}
