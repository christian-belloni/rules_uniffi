package my_lib;

import uniffi.crate_2.*;
import uniffi.crate_1.*;
import org.junit.*
import org.junit.Assert.*;


class AddTest {
  @Test
  fun assertAddWorks() {
    val res: UByte = 3u;
    assertEquals(res, myAdd(2u, 1u))
  }
  @Test
  fun assertNestedAddWorks() {
    val res: UByte = 3u;
    assertEquals(res, myNestedAdd(2u, 1u))
  }
}
