import XCTest
@testable import QRReader

final class QRReaderTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(QRReader().text, "Hello, World!")
    }
}
