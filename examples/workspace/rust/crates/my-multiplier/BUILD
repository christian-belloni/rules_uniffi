load("@rules_rust//rust:defs.bzl", "rust_library")
load("@crates//:defs.bzl", "all_crate_deps")

rust_library(
  name = "my-multiplier",
  srcs = glob(["src/**/*.rs"]),
  deps = all_crate_deps(),
  visibility = ["//rust:__subpackages__"],
  compile_data = [":Cargo.toml"],
)
