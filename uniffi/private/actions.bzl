
load("@rules_cc//cc:defs.bzl", "CcInfo")
load(":providers.bzl", "UniffiKotlinInfo", "UniffiSwiftInfo")


# SWIFT_ARGS = ["--swift-sources", "--headers"]
KOTLIN_ARGS = ["generate", "-l", "kotlin", "--no-format", "--out-dir"]
SWIFT_ARGS = ["generate", "-l", "swift", "--no-format", "--out-dir"]

def generate(*, name, actions, executable, language, library, uniffi_toml):
  outdir = actions.declare_directory("__{}_{}_outdir".format(name, language))
  args = []
  if language == "swift":
    args = SWIFT_ARGS + [outdir.path, library.path] + ["--config", uniffi_toml.path]
  elif language == "kotlin":
    args = KOTLIN_ARGS + [outdir.path, library.path] + ["--config", uniffi_toml.path]
  else:
    fail("language must be one of [swift, kotlin], was %s" % language)

  actions.run(
    executable = executable,
    inputs = [library, uniffi_toml],
    outputs = [outdir],
    arguments = args
  )
  return outdir


IMPORT_TEMPLATE = """
#if canImport({module}FFI)
import {module}FFI
#endif

"""
def extract_kotlin_info(*, actions, kotlin_dir, main_crate, deps, shared_library):
  main_src = actions.declare_file("%s.kt" % main_crate)

  actions.run_shell(
    command = "cp {0}/uniffi/{1}/{1}.kt {2}".format(kotlin_dir.path, main_crate, main_src.path),
    inputs = [kotlin_dir],
    outputs=[main_src]
  )

  dep_srcs = []
  for dep in deps:
    dep_src = actions.declare_file("%s.kt" % dep)
    actions.run_shell(
      command = "cp {0}/uniffi/{1}/{1}.kt {2}".format(kotlin_dir.path, dep, dep_src.path),
      inputs = [kotlin_dir],
      outputs=[dep_src]
    )
    dep_srcs.append(dep_src)

  shared_providers = []
  shared_providers.append(shared_library[DefaultInfo])
  shared_providers.append(shared_library[CcInfo])

  return UniffiKotlinInfo(
    shared_library = shared_providers,
    srcs = DefaultInfo(files = depset([main_src] + dep_srcs)),
  )

def extract_swift_info(*, actions, swift_dir, main_crate, deps, static_library):
  main_src = actions.declare_file("%s.swift" % main_crate)
  actions.run_shell(
    command = "cp {}/{}.swift {}".format(swift_dir.path, main_crate, main_src.path),
    inputs = [swift_dir],
    outputs = [main_src]
  )

  main_hdr = actions.declare_file("%sFFI.h" % main_crate)
  actions.run_shell(
    command = "cp {}/{}FFI.h {}".format(swift_dir.path, main_crate, main_hdr.path),
    inputs = [swift_dir],
    outputs = [main_hdr]
  )

  srcs = [main_src]
  hdrs = [main_hdr]

  import_header = [IMPORT_TEMPLATE.replace("{module}", main_crate)]

  import_header += [ IMPORT_TEMPLATE.replace("{module}", x) for x in deps ]

  import_header = "\n".join(import_header)

  for dep in deps:
    dep_src = actions.declare_file("%s.swift" % dep)
    actions.run_shell(
      command = "echo '{3}' > {2} && cat {0}/{1}.swift >> {2}".format(swift_dir.path, dep, dep_src.path, import_header),
      inputs = [swift_dir],
      outputs = [dep_src]
    )
    srcs.append(dep_src)
    dep_hdr = actions.declare_file("%sFFI.h" % dep)
    actions.run_shell(
      command = "cp {}/{}FFI.h {}".format(swift_dir.path, dep, dep_hdr.path),
      inputs = [swift_dir],
      outputs = [dep_hdr]
    )
    hdrs.append(dep_hdr)
  
  static_providers = []
  static_providers.append(static_library[DefaultInfo])
  static_providers.append(static_library[CcInfo])

  return UniffiSwiftInfo(
    static_library = static_providers,
    module_name = main_crate,
    srcs = DefaultInfo(files=depset(srcs)),
    hdrs = DefaultInfo(files=depset(hdrs))
  )
  
  
