load("@rules_uniffi//uniffi:defs.bzl", "uniffi_rust_library", "uniffi_swift_library", "uniffi_kotlin_library")
load("@rules_swift//swift:swift.bzl", "swift_binary")
load("@rules_kotlin//kotlin:jvm.bzl", "kt_jvm_binary")
load("@crates//:defs.bzl", "all_crate_deps")

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

swift_binary(
    name = "swift-bin",
    deps = [":swift_lib"],
    srcs = [":main.swift"]
)

uniffi_kotlin_library(
    name = "kotlin_lib",
    library = ":my-lib"
)

kt_jvm_binary(
    name = "kotlin-bin",
    main_class = "MainClass",
    srcs = [":main.kt"],
    deps = [":kotlin_lib"],
)
