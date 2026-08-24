load(":providers.bzl", "UniffiKotlinInfo")
load("@rules_android//rules:rules.bzl", "android_library")
load("@rules_kotlin//kotlin:jvm.bzl", "kt_jvm_library")
load("@rules_java//java:java_library.bzl", "java_library")

def _uniffi_srcs_impl(ctx):
  info = ctx.attr.uniffi_library[UniffiKotlinInfo]

  return info.srcs


_uniffi_srcs = rule(
  implementation = _uniffi_srcs_impl,
  attrs = {
    "uniffi_library": attr.label(providers = [UniffiKotlinInfo]),
  },
)

def _uniffi_lib_impl(ctx):
  info = ctx.attr.uniffi_library[UniffiKotlinInfo]

  return info.shared_library


_uniffi_lib = rule(
  implementation = _uniffi_lib_impl,
  attrs = {
    "uniffi_library": attr.label(providers = [UniffiKotlinInfo]),
  },
)

def uniffi_kotlin(name, uniffi_library, **kwargs):
  _uniffi_srcs(
    name = "__%s_srcs" % name,
    uniffi_library = uniffi_library,
    visibility = ["//visibility:private"]
  )

  _uniffi_lib(
    name = "__%s_lib" % name,
    uniffi_library = uniffi_library,
    visibility = ["//visibility:private"]
  )

  kt_jvm_library(
    name = "__%s_kt" % name,
    srcs = [":__%s_srcs" % name],
    deps = ["@rules_uniffi//3rdparty:jna", "@rules_uniffi//3rdparty:coroutines"],
    visibility = ["//visibility:private"]
  )

  java_library(
    name = "__%s_java" % name,
    runtime_deps = [":__%s_lib" % name]
  )

  kt_jvm_library(
    name = name,
    exports = ["__%s_java" % name, "__%s_kt" % name, "@rules_uniffi//3rdparty:jna", "@rules_uniffi//3rdparty:coroutines"],
    **kwargs
  )

def uniffi_android(name, uniffi_library, **kwargs):
  _uniffi_srcs(
    name = "__%s_srcs" % name,
    uniffi_library = uniffi_library,
    visibility = ["//visibility:private"]
  )

  _uniffi_lib(
    name = "__%s_lib" % name,
    uniffi_library = uniffi_library,
    visibility = ["//visibility:private"]
  )

  kt_jvm_library(
    name = "__%s_kt" % name,
    srcs = [":__%s_srcs" % name],
    deps = ["@rules_uniffi//3rdparty:jna", "@rules_uniffi//3rdparty:coroutines"],
    visibility = ["//visibility:private"]
  )

  android_library(
    name = name,
    exports = ["__%s_lib" % name, "__%s_kt" % name, "@rules_uniffi//3rdparty:jna", "@rules_uniffi//3rdparty:coroutines"],
    **kwargs
  )
