load("@rules_android//android:rules.bzl", "android_binary")
load("@rules_uniffi//uniffi:defs.bzl", "uniffi_rust_library", "uniffi_android_library")
load("@rules_kotlin//kotlin:android.bzl", "kt_android_library")

# An app that consumes android-kt deps
android_binary(
    name = "app",
    custom_package = "example.library.app",
    manifest = "src/main/AndroidManifest.xml",
    deps = [
        ":lib",
    ],
)

kt_android_library(
    name = "lib",
    srcs = glob(["src/main/java/**/*.kt"]),
    deps = ["//rust:gen-lib"]
)
