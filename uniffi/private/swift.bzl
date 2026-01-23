load(":providers.bzl", "UniffiSwiftInfo")
load("@rules_cc//cc:cc_library.bzl", "cc_library")
load("@rules_swift//swift:swift_library.bzl", "swift_library")
load("@rules_swift//swift:swift_interop_hint.bzl", "swift_interop_hint")

def _uniffi_hdrs_impl(ctx):
  info = ctx.attr.uniffi_library[UniffiSwiftInfo]

  return info.hdrs

_uniffi_hdrs = rule(
  implementation = _uniffi_hdrs_impl,
  attrs = {
    "uniffi_library": attr.label(providers = [UniffiSwiftInfo]),
  }
)

def _uniffi_srcs_impl(ctx):
  info = ctx.attr.uniffi_library[UniffiSwiftInfo]

  return info.srcs

_uniffi_srcs = rule(
  implementation = _uniffi_srcs_impl,
  attrs = {
    "uniffi_library": attr.label(providers = [UniffiSwiftInfo]),
  }
)

def _uniffi_static_impl(ctx):
  info = ctx.attr.uniffi_library[UniffiSwiftInfo]

  return info.static_library

_uniffi_static = rule(
  implementation = _uniffi_static_impl,
  attrs = {
    "uniffi_library": attr.label(providers = [UniffiSwiftInfo]),
  }
)

def uniffi_swift(*, name, ffi_module_name, uniffi_library, **kwargs):
  _uniffi_hdrs(
    name = "__%s_hdrs" % name,
    uniffi_library = uniffi_library,
    visibility = ["//visibility:private"]
  )

  _uniffi_static(
    name = "__%s_lib" % name,
    uniffi_library = uniffi_library,
    visibility = ["//visibility:private"]
  )

  swift_interop_hint(
    name = "__%s_interop_hint" % name,
    module_name = ffi_module_name + "FFI",
    visibility = ["//visibility:private"]
  )

  cc_library(
    name = "__%s_static" % name,
    hdrs = ["__%s_hdrs" % name],
    deps = ["__%s_lib" % name],
    aspect_hints = [":__%s_interop_hint" % name],
    visibility = ["//visibility:private"],
    tags = ["manual"],
  )

  _uniffi_srcs(
    name = "__%s_srcs" % name,
    uniffi_library = uniffi_library,
    visibility = ["//visibility:private"]
  )

  swift_library(
    name = name,
    srcs = ["__%s_srcs" % name],
    deps = ["__%s_static" % name],
    alwayslink = True,
    **kwargs
  )
