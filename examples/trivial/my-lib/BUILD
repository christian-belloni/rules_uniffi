load("@crates//:defs.bzl", "all_crate_deps")
load("@rules_rust//rust:defs.bzl", "rust_library", "rust_static_library", "rust_shared_library")


rust_library(
  name = "my-lib",
  srcs = glob(["src/**/*.rs"]),
  compile_data = ["Cargo.toml"],
  deps = all_crate_deps(),
  visibility = ["//visibility:public"]
)

rust_static_library(
  name = "my-lib-static",
  crate_name = "my_lib",
  srcs = glob(["src/**/*.rs"]),
  compile_data = ["Cargo.toml"],
  deps = all_crate_deps(),
  visibility = ["//visibility:public"]
)

rust_shared_library(
  name = "my-lib-shared",
  crate_name = "my_lib",
  srcs = glob(["src/**/*.rs"]),
  compile_data = ["Cargo.toml"],
  deps = all_crate_deps(),
  visibility = ["//visibility:public"]
)
