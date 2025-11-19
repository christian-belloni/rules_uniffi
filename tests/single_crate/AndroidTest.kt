package my_lib;


import uniffi.my_lib.*;
import org.junit.*
import org.junit.Assert.*;


class AddTest {
  @Test
  fun assertAddWorks() {
    val res: UByte = 3u;
    assertEquals(res, myAdd(2u, 1u))
  }
}
