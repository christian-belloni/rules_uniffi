load(":providers.bzl", "UniffiDepInfo")
load("@rules_rust//rust:rust_common.bzl", "CrateInfo", "DepInfo")

def _dependency_aspect_impl(target, ctx):
  main_crate = target.label.name.replace("-", "_")
  generated_files = []
  if ctx.rule.kind != "rust_library":
    return []
  for dep in ctx.rule.attr.deps:
    if not dep.label.package:
      continue
    if not DepInfo in dep:
        continue

    dep_info = dep[DepInfo]
    is_uniffi_crate = False
    for direct in dep_info.direct_crates.to_list():
      if direct.dep.name == "uniffi":
        is_uniffi_crate = True
        break
    if is_uniffi_crate:
      filename = dep[CrateInfo].name.replace("-", "_")
      if filename not in generated_files:
        generated_files += [filename]

  return UniffiDepInfo(
    main_crate = main_crate,
    deps = generated_files
  )

dependency_aspect = aspect(
  implementation = _dependency_aspect_impl,
  attr_aspects = ["deps"]
)
