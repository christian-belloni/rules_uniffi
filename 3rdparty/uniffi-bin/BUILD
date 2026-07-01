load("@u_deps//:defs.bzl", "aliases", "all_crate_deps")
load("@rules_rs//rs:rust_binary.bzl", "rust_binary")


rust_binary(
    name = "uniffi-bin",
    srcs = ["src/standard.rs"],
    aliases = aliases(),
    deps = all_crate_deps(normal = True),
    visibility = ["//tools:__subpackages__"]
)
