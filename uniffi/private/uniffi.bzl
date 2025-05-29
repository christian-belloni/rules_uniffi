load(":providers.bzl", "UniffiInfo")
load("@rules_rust//rust:defs.bzl", "rust_library", "rust_static_library", "rust_shared_library")
load("@rules_swift//swift:swift_interop_hint.bzl", "swift_interop_hint")


def _generate_sources(
    actions, 
    language, 
    parent, 
    lib, 
    crate_name, 
    cargo_toml, 
    srcs,
    outputs,
    uniffi_bin, 
    cargo_bin, 
):
    actions.run(
        inputs = [lib, cargo_toml] + srcs,
        outputs = outputs,
        tools = [cargo_bin],
        executable = uniffi_bin,
        arguments = ["generate", "--library", lib.path, "--out-dir", parent, "--language", language, "--no-format"],
        mnemonic = "UniffiGenerate",
        env = {
            "CARGO": cargo_bin.path,
            "OUT_DIR": parent,
            "LIB_NAME": crate_name,
            "LANG": language
        }
    )

    return outputs


def _generate_kotlin(actions, crate_name, uniffi_bin, cdylib, cargo_bin, cargo_toml, srcs):
    
    out_kt = actions.declare_file("{0}.kt".format(crate_name))
    parent = out_kt.path.replace("/{0}.kt".format(crate_name), "")

    outputs = [out_kt]

    _generate_sources(
        actions = actions,
        language = "kotlin",
        parent = parent,
        lib = cdylib,
        crate_name = crate_name,
        cargo_toml = cargo_toml,
        srcs = srcs,
        outputs = outputs,
        uniffi_bin = uniffi_bin,
        cargo_bin = cargo_bin,
    )

    return out_kt

def _generate_swift(actions, crate_name, uniffi_bin, staticlib, cargo_bin, cargo_toml, srcs):
    out_swift = actions.declare_file("{0}.swift".format(crate_name))
    out_h = actions.declare_file("{0}FFI.h".format(crate_name))
    out_modulemap = actions.declare_file("{0}FFI.modulemap".format(crate_name))
    
    parent = out_swift.path.replace("/{0}.swift".format(crate_name), "")

    outputs = [out_swift, out_h, out_modulemap]

    _generate_sources(
        actions = actions,
        language = "swift",
        parent = parent,
        lib = staticlib,
        crate_name = crate_name,
        cargo_toml = cargo_toml,
        srcs = srcs,
        outputs = outputs,
        uniffi_bin = uniffi_bin,
        cargo_bin = cargo_bin,
    )

    return outputs

def _uniffi_library(ctx):
    cargo_bin = ctx.executable._cargo
    uniffi_bin = ctx.executable._uniffi_bin
    
    cargo_toml = ctx.file.cargo_toml
    staticlib = ctx.attr.static_lib[DefaultInfo].files.to_list()[0]
    sharedlib = ctx.attr.shared_lib[DefaultInfo].files.to_list()[0]
    srcs = ctx.files.srcs

    crate_name = ctx.attr.crate_name.replace("-", "_")

    out_kt = _generate_kotlin(ctx.actions, crate_name, uniffi_bin, sharedlib, cargo_bin, cargo_toml, srcs)
    [out_swift, out_h, out_modulemap] = _generate_swift(ctx.actions, crate_name, uniffi_bin, staticlib, cargo_bin, cargo_toml, srcs)

    info = UniffiInfo(
        kotlin_source = out_kt,
        shared_library = sharedlib,
        swift_source = out_swift,
        c_header = out_h,
        module_map = out_modulemap,
    )

    return [info]


uniffi_library = rule(
    implementation = _uniffi_library,
    attrs = {
        "crate_name": attr.string(mandatory = True),
        "static_lib": attr.label(providers = [DefaultInfo, CcInfo], mandatory = True),
        "shared_lib": attr.label(providers = [DefaultInfo, CcInfo], mandatory = True),
        "cargo_toml": attr.label(mandatory = True, allow_single_file = True),
        "srcs": attr.label_list(mandatory = True, allow_files = [".rs"]),
        "_uniffi_bin": attr.label(default = Label("@rules_uniffi//tools:uniffi_bin"), executable = True, cfg = "host"),
        "_cargo": attr.label(default = Label("@rules_rust//tools/upstream_wrapper:cargo"), executable = True, cfg = "host"),
    },
)


def uniffi_rust_library(name, cargo_toml, **kwargs):
    kwargs.setdefault("compile_data", [])
    kwargs["compile_data"] += [cargo_toml]

    crate_name = name.replace("-", "_")

    rust_library(
        name = "%s-rust" % name,
        crate_name = crate_name,
        **kwargs
    )

    rust_static_library(
        name = "%s-static" % name,
        crate_name = crate_name,
        **kwargs
    )

    rust_shared_library(
        name = "%s-shared" % name,
        crate_name = crate_name,
        **kwargs
    )

    uniffi_library(
        name = name,
        crate_name = crate_name,
        static_lib = ":%s-static" % name,
        shared_lib = ":%s-shared" % name,
        cargo_toml = cargo_toml,
        srcs = kwargs["srcs"]
    )
