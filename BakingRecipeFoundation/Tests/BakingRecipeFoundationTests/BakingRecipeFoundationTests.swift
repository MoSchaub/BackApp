import XCTest
@testable import BakingRecipeFoundation

final class BakingRecipeFoundationTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        //XCTAssertEqual(BakingRecipe().text, "Hello, World!")
    }
    
    func testComplexTemp() {
        let recipe = Recipe.complexExample
        let step = recipe.steps.last!
        let ingredient = step.ingredients[1]
        let expectation = 22
        XCTAssertEqual(step.themperature(for: ingredient, roomThemperature: 23), expectation)
    }

    static var allTests = [
        ("testExample", testExample),
        ("testComplexTemp", testComplexTemp)
    ]
}
