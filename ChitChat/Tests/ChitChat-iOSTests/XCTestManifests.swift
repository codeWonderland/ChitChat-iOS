import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(ChitChat_iOSTests.allTests),
    ]
}
#endif