load(":aspects.bzl", "dependency_aspect")
load(":actions.bzl", "generate", "extract_kotlin_info", "extract_swift_info")
load(":providers.bzl", "UniffiDepInfo", "UniffiKotlinInfo", "UniffiSwiftInfo")
load("@rules_cc//cc:defs.bzl", "CcInfo")
load("@rules_rust//rust:rust_common.bzl", "CrateInfo")


def _uniffi_library(ctx):
  dep_info = ctx.attr.library[UniffiDepInfo]

  swift_dir = generate(
    actions=ctx.actions,
    name=ctx.attr.name,
    language = "swift",
    executable = ctx.executable._uniffi_swift,
    library = ctx.file.static_library,
    uniffi_toml = ctx.file.uniffi_toml
  )

  kotlin_dir = generate(
    actions=ctx.actions,
    name=ctx.attr.name,
    language = "kotlin",
    executable = ctx.executable._uniffi,
    library = ctx.file.shared_library,
    uniffi_toml = ctx.file.uniffi_toml
  )

  kotlin_info = extract_kotlin_info(
    actions=ctx.actions,
    kotlin_dir=kotlin_dir,
    main_crate=dep_info.main_crate,
    deps=dep_info.deps,
    shared_library = ctx.attr.shared_library
  )

  swift_info = extract_swift_info(
    actions=ctx.actions,
    swift_dir=swift_dir,
    main_crate=dep_info.main_crate,
    deps=dep_info.deps,
    static_library=ctx.attr.static_library
  )

  return [kotlin_info, swift_info]



uniffi_library = rule(
  implementation = _uniffi_library,
  attrs = {
    "library": attr.label(providers = [CrateInfo], aspects = [dependency_aspect]),
    "static_library": attr.label(providers=[CcInfo], allow_single_file = True),
    "shared_library": attr.label(providers=[CcInfo], allow_single_file = True),
    "uniffi_toml": attr.label(allow_single_file = True),
    "_uniffi": attr.label(executable = True, cfg = "exec", default=Label("@rules_uniffi//tools:uniffi")),
    "_uniffi_swift": attr.label(executable = True, cfg = "exec", default=Label("@rules_uniffi//tools:uniffi")),
  }
)
