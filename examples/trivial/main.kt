import uniffi.my_lib.add;

public class MainClass {
    companion object {
        @JvmStatic
        public fun main(args: Array<String>) {
            print("Hello world ${add(3.toUByte(), 6.toUByte())}")
        }
    }
}
