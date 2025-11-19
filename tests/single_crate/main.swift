import my_lib
import XCTest


class AddTests: XCTestCase {
    func testAddWorks() {
        XCTAssertEqual(8, my_lib.myAdd(3, 5))
    }
}
