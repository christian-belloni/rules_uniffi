load("@rules_uniffi//rules:defs.bzl", "uniffi_library", "uniffi_rust_library", "uniffi_swift_library", "uniffi_kotlin_library")
load("@crates//:defs.bzl", "all_crate_deps")
load("@rules_rust//rust:defs.bzl", "rust_library", "rust_static_library", "rust_shared_library")
load("@rules_swift//swift:swift.bzl", "swift_library")
load("@rules_kotlin//kotlin:jvm.bzl", "kt_jvm_library", "kt_jvm_binary")

uniffi_rust_library(
    name = "my-lib",
    cargo_toml = ":Cargo.toml",
    deps = all_crate_deps(),
    proc_macro_deps = all_crate_deps(proc_macro = True),
    srcs = glob(["src/**/*.rs"])
)

uniffi_swift_library(
    name = "swift_lib",
    library = ":my-lib",
    module_name = "MyLibrary"
)

swift_library(
    name = "swift-consumer",
    deps = [":swift_lib"],
    srcs = [":main.swift"]
)

uniffi_kotlin_library(
    name = "kotlin_lib",
    library = ":my-lib"
)

kt_jvm_binary(
    name = "kotlin-consumer",
    main_class = "MainClass",
    srcs = [":main.kt"],
    deps = [":kotlin_lib"] + ["@rules_uniffi//3rdparty:jna", "@rules_uniffi//3rdparty:coroutines"],
)
