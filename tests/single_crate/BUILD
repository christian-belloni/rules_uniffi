load("@rules_rust//rust:defs.bzl", "rust_library", "rust_shared_library", "rust_static_library")
load("@rules_swift//swift:swift.bzl", "swift_library", "swift_binary", "swift_test")
load("//uniffi:defs.bzl", "uniffi_swift_library", "uniffi_kotlin_library", "uniffi_android_library")

load("@rules_kotlin//kotlin:jvm.bzl", "kt_jvm_test")
load("@rules_kotlin//kotlin:android.bzl", "kt_android_local_test")


rust_library(
    name = "my-lib",
    srcs = ["my_library.rs"],
    deps = ["@crates//:uniffi-0.30.0"],
    compile_data = ["Cargo.toml"],
    visibility = ["//visibility:public"],
    alwayslink = True
)

rust_static_library(
    name = "my-lib_static",
    crate_name = "my_lib",
    srcs = ["my_library.rs"],
    deps = ["@crates//:uniffi-0.30.0"],
    compile_data = ["Cargo.toml"],
    visibility = ["//visibility:public"],
)

uniffi_swift_library(
    name = "my-swift-lib",
    library = "my-lib",
    uniffi_crates = ["my_lib"]
)

uniffi_kotlin_library(
    name = "my-kotlin-lib",
    library = ":my-lib"
)

# uniffi_android_library(
#     name = "my-android-lib",
#     library = ":my-lib"
# )

swift_library(
    name = "transitive",
    srcs = ["transitive.swift"],
    deps = [":my-swift-lib"],
)

swift_test(
    name = "my-swift-bin",
    deps = ["transitive"],
    srcs = ["main.swift"],
)

# Currently broken as test, works in actual android app
# kt_android_local_test(
#     srcs = ["Main.kt"],
#     name = "my-android-bin",
#     custom_package = "my_lib.tests",
#     deps = ["my-android-lib"],
#     test_class = "my_lib.AddTest",
# )

kt_jvm_test(
    name = "my-kotlin-bin",
    deps = [
        "my-kotlin-lib", 
        "@uniffi_maven//:junit_junit",
    ],
    test_class = "my_lib.AddTest",
    srcs = ["Main.kt"],
)
