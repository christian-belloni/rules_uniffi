load("@rules_uniffi//uniffi:defs.bzl", "uniffi_library")

uniffi_library(
  name = "uniffi-lib",
  library = "//rust/my-artifact",
  static_library = "//rust/my-artifact:my-artifact_static",
  shared_library = "//rust/my-artifact:my-artifact_shared",
  visibility = ["//visibility:public"]
)
