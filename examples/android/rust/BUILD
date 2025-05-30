exports_files(srcs = ["Cargo.toml", "Cargo.lock"], visibility=["//visibility:public"])
load("@rules_uniffi//uniffi:defs.bzl", "uniffi_rust_library", "uniffi_android_library")
load("@crates//:defs.bzl", "all_crate_deps")

uniffi_rust_library(
    name = "my-lib",
    cargo_toml = "Cargo.toml",
    deps = all_crate_deps(),
    proc_macro_deps = all_crate_deps(proc_macro = True),
    srcs = glob(["src/**/*.rs"]),
    visibility = ["//visibility:public"],
)

uniffi_android_library(
    name = "gen-lib",
    library = "//rust:my-lib",
    visibility = ["//visibility:public"],
)
