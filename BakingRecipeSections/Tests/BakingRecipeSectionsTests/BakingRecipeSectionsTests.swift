import XCTest
@testable import BakingRecipeSections

final class BakingRecipeSectionsTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(BakingRecipeSections().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
