load("@rules_rust//rust:defs.bzl", "rust_library", "rust_shared_library", "rust_static_library")
load("@rules_swift//swift:swift.bzl", "swift_library", "swift_binary", "swift_test")
load("//uniffi/private:swift.bzl", "uniffi_swift_library")


test_suite(
    name = "swift_tests",
    tests = [
        "//tests/single_crate:my-swift-bin",
        "//tests/multi_crates:my-swift-bin"
    ],
    visibility = ["//visibility:public"],
)

test_suite(
    name = "kotlin_tests",
    tests = [
        "//tests/single_crate:my-kotlin-bin",
        "//tests/multi_crates:my-kotlin-bin"
    ],
    visibility = ["//visibility:public"],
)

test_suite(
    name = "all_tests",
    tests = [
        "swift_tests",
        "kotlin_tests"
    ],
    visibility = ["//visibility:public"],
)
