import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(BakingRecipeTests.allTests),
    ]
}
#endif
