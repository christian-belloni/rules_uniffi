load("@rules_uniffi//uniffi:defs.bzl", "uniffi_swift")
load("@rules_swift//swift:swift_binary.bzl", "swift_binary")


uniffi_swift(
  name = "uniffi_swift",
  uniffi_library = "//rust:uniffi-lib",
  module_name = "my_artifact"
)

swift_binary(
  name = "macos",
  srcs = ["main.swift"],
  deps = [":uniffi_swift"]
)
