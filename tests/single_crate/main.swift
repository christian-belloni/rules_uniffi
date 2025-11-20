import my_lib
import XCTest



class AddTests: XCTestCase {
    func testAddWorks() {
        my_lib.uniffiEnsureMyLibInitialized()
        XCTAssertEqual(8, my_lib.myAdd(3, 5))
    }
}
