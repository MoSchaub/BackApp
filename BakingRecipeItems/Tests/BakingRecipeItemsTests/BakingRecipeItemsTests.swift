import XCTest
@testable import BakingRecipeItems

final class BakingRecipeItemsTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(BakingRecipeItems().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
