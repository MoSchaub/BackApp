import XCTest
@testable import BakingRecipeExtra

final class BakingRecipeExtraTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(BakingRecipeExtra().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
