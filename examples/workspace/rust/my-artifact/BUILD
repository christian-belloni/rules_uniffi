load("@crates//:defs.bzl", "all_crate_deps")


load("@rules_rust//rust:defs.bzl", "rust_library", "rust_shared_library", "rust_static_library")

rust_library(
  name = "my-artifact",
  srcs = glob(["src/**/*.rs"]),
  deps = all_crate_deps() + ["//rust/crates/my-multiplier", "//rust/crates/my-adder"],
  compile_data = [":Cargo.toml"],
  alwayslink = True,
  visibility = ["//visibility:public"]
)

rust_shared_library(
  name = "my-artifact_shared",
  crate_name = "my_artifact",
  srcs = glob(["src/**/*.rs"]),
  deps = all_crate_deps() + ["//rust/crates/my-multiplier", "//rust/crates/my-adder"],
  compile_data = [":Cargo.toml"],
  alwayslink = True,
  visibility = ["//visibility:public"]
)

rust_static_library(
  name = "my-artifact_static",
  crate_name = "my_artifact",
  srcs = glob(["src/**/*.rs"]),
  deps = all_crate_deps() + ["//rust/crates/my-multiplier", "//rust/crates/my-adder"],
  compile_data = [":Cargo.toml"],
  alwayslink = True,
  visibility = ["//visibility:public"]
)
