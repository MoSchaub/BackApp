import XCTest
@testable import BackAppJson

final class BackAppJsonTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(BackAppJson().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
