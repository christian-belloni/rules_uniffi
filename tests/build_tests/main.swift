
import XCTest
import tests_build_tests_test_swift_library

class BaseTest: XCTestCase {
    /// Tests that a new table instance has zero rows and columns.
    func testAddWorks() {
        XCTAssertEqual(myFunction(left:3, right: 5), 8, "3 + 8 wasn't 8")
    }
}
