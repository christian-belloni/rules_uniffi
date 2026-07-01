load("@rules_rust//rust:defs.bzl", "rust_library", "rust_shared_library", "rust_static_library")

rust_shared_library(
    name = "crate-2-shared",
    crate_name = "crate_2",
    srcs = ["my_library_2.rs"],
    deps = ["@crates//:uniffi-0.30.0", "//tests/multi_crates/crate-1"],
    compile_data = ["Cargo.toml"],
    visibility = ["//visibility:public"],
    alwayslink = True
)

# rust_static_library(
#     name = "crate-2-static",
#     crate_name = "crate_2",
#     srcs = ["my_library_2.rs"],
#     deps = ["@crates//:uniffi-0.30.0", "//tests/multi_crates/crate-1"],
#     compile_data = ["Cargo.toml"],
#     visibility = ["//visibility:public"],
#     alwayslink = True
# )

rust_library(
    name = "crate-2",
    srcs = ["my_library_2.rs"],
    deps = ["@crates//:uniffi-0.31.0", "//tests/multi_crates/crate-1"],
    compile_data = ["Cargo.toml"],
    visibility = ["//visibility:public"],
    alwayslink = True
)

cc_binary(
    name = "crate-2-static",
    deps = ["crate-2"],
    linkshared = True,
    linkstatic = True,
)
