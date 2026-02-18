load("@rules_uniffi//uniffi:utils.bzl", "uniffi_crate")
load("@rules_uniffi//uniffi:defs.bzl","uniffi_library", "uniffi_swift", "uniffi_android")
load("@rules_swift//swift:swift.bzl", "swift_test")

uniffi_crate(
  name = "test-library",
  srcs = [":lib.rs"],
  deps = ["@build_test_crates//:uniffi"],
  compile_data = [":Cargo.toml"]
)

uniffi_library(
  name = "test-uniffi-library",
  library = ":test-library",
  static_library = ":test-library_static",
  shared_library = ":test-library_shared",
)

uniffi_swift(
  name = "test-swift-library",
  uniffi_library = ":test-uniffi-library",
  ffi_module_name = "test_library",
  module_name = "test_library"
)

swift_test(
  name = "swift-test",
  srcs = [":main.swift"],
  deps = [":test-swift-library"]
)
