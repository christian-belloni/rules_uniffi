import crate_2


import XCTest


class AddTests: XCTestCase {
    func testAddWorks() {
        XCTAssertEqual(8, myAdd(3, 5))
    }

    func testNestedAddWorks() {
        XCTAssertEqual(4, myNestedAdd(1, 3))
    }
}
