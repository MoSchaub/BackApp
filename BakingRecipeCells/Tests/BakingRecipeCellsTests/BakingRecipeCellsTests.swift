import XCTest
@testable import BakingRecipeCells

final class BakingRecipeCellsTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(BakingRecipeCells().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
