load("@rules_uniffi//uniffi:defs.bzl", "uniffi_library", "uniffi_swift", "uniffi_android", "uniffi_kotlin")
load("@rules_swift//swift:swift_binary.bzl", "swift_binary")
load("@rules_kotlin//kotlin:jvm.bzl", "kt_jvm_library")
load("@rules_kotlin//kotlin:jvm.bzl", "kt_jvm_binary")
load("@rules_java//java:java_library.bzl", "java_library")
load("@rules_java//java:java_binary.bzl", "java_binary")
load("@rules_cc//cc:cc_binary.bzl", "cc_binary")
load("@rules_cc//cc:cc_import.bzl", "cc_import")
load("@bazel_lib//lib:copy_file.bzl", "copy_file")

uniffi_library(
  name = "uniffi-lib",
  library = "//my-lib",
  static_library = "//my-lib:my-lib-static",
  shared_library = "//my-lib:my-lib-shared",
)

uniffi_swift(
  name = "uniffi_swift",
  ffi_module_name = "uniffi_swift",
  uniffi_library = ":uniffi-lib",
  module_name = "my_lib",
)

swift_binary(
  name = "swift-bin",
  srcs = ["main.swift"],
  deps = [":uniffi_swift"]
)

uniffi_android(
  name = "android-lib",
  uniffi_library = ":uniffi-lib"
)

uniffi_kotlin(
  name = "kotlin-lib",
  uniffi_library = ":uniffi-lib"
)
