load("@rules_rust//rust:defs.bzl", "rust_library")

rust_library(
    name = "crate-1",
    srcs = ["my_library_1.rs"],
    deps = ["@crates//:uniffi-0.30.0"],
    compile_data = ["Cargo.toml"],
    visibility = ["//visibility:public"],
)
