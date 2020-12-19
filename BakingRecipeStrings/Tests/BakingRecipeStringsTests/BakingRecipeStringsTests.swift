import XCTest
@testable import BakingRecipeStrings

final class BakingRecipeStringsTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(BakingRecipeStrings().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
