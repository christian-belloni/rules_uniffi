


load("@rules_uniffi//uniffi:defs.bzl", "uniffi_library", "uniffi_swift", "uniffi_android")
load("@rules_swift//swift:swift_binary.bzl", "swift_binary")



uniffi_library(
  name = "uniffi-lib",
  library = "//my-lib",
  static_library = "//my-lib:my-lib-static",
  shared_library = "//my-lib:my-lib-shared",
)

uniffi_swift(
  name = "uniffi_swift",
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
