import crate_1
import crate_2


import XCTest


class AddTests: XCTestCase {
    func testAddWorks() {
        uniffiEnsureCrate2Initialized()
        XCTAssertEqual(8, myAdd(3, 5))
    }

    func testNestedAddWorks() {
        uniffiEnsureCrate2Initialized()
        XCTAssertEqual(4, myNestedAdd(1, 3))
    }
}
