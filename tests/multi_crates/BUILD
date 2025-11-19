load("@rules_swift//swift:swift.bzl", "swift_test")
load("//uniffi:defs.bzl", "uniffi_kotlin_library", "uniffi_swift_library")
load("@rules_kotlin//kotlin:jvm.bzl", "kt_jvm_test")

uniffi_swift_library(
    name = "my-swift-lib",
    library = "//tests/multi_crates/crate-2"
)

uniffi_kotlin_library(
    name = "my-kotlin-lib",
    library = "//tests/multi_crates/crate-2",
)

swift_test(
    name = "my-swift-bin",
    deps = [":my-swift-lib"],
    srcs = ["main.swift"],
)

kt_jvm_test(
    name = "my-kotlin-bin",
    deps = [
        ":my-kotlin-lib",
        "@uniffi_maven//:junit_junit",
    ],
    srcs = ["Main.kt"],
    test_class = "my_lib.AddTest",
    jvm_flags = ["--enable-native-access=ALL-UNNAMED"]
)
