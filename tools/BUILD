load("@rules_rust//rust:rust_binary.bzl", "rust_binary")
load("@uniffi_crates//:defs.bzl", "all_crate_deps")

exports_files(["Cargo.toml", "Cargo.lock"])

rust_binary(
    name = "uniffi_bin",
    srcs = ["src/main.rs"],
    deps = all_crate_deps(),
    visibility = ["//visibility:public"]
)
