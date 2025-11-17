load("@rules_rust//rust:defs.bzl", "rust_library", "rust_shared_library", "rust_static_library")

load("//uniffi/private:uniffi.bzl", "uniffi_library", "tmp_shared", "uniffi_swift_library")
load("@rules_swift//swift:swift.bzl", "swift_library")


rust_library(
    name = "my-lib",
    srcs = ["my_library.rs"],
    deps = ["@crates//:uniffi-0.30.0"],
    compile_data = ["Cargo.toml"],
)

rust_shared_library(
    name = "my-lib-shared",
    srcs = ["my_library.rs"],
    deps = ["@crates//:uniffi-0.30.0"],
    compile_data = ["Cargo.toml"],
)

rust_static_library(
    name = "my-lib-static",
    srcs = ["my_library.rs"],
    deps = ["@crates//:uniffi-0.30.0"],
    compile_data = ["Cargo.toml"],
)

uniffi_library(
    name = "my-uniffi-lib",
    rust_library = ":my-lib",
    shared_library = ":my-lib-shared",
    static_library = ":my-lib-static",
)

tmp_shared(
    name = "tmp-shared-lib",
    uniffi_library = ":my-uniffi-lib"
)

uniffi_swift_library(
    name = "my-swift-lib",
    uniffi_library = ":my-uniffi-lib"
)

swift_library(
    name = "swift-dependent",
    deps = [":my-swift-lib"],
    srcs = ["MyLibrary.swift"]
)
