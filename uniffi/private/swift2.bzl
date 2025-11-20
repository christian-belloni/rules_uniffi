load(":common.bzl", "generate_src_action")
load("@rules_swift//swift:swift_library.bzl", "swift_library")
load("@rules_swift//swift:swift_library_group.bzl", "swift_library_group")
load("@rules_swift//swift:swift_interop_hint.bzl", "swift_interop_hint")
load("@rules_swift//swift:module_name.bzl", "derive_swift_module_name")

def _process_dir(actions, crate_name, in_dir):
    src = actions.declare_file("%s.swift" % crate_name)
    header = actions.declare_file("%s.h" % crate_name)

    actions.run_shell(
        command = """
        cp $2/$1*.swift $3
        cp $2/$1*.h $4
        """,
        arguments = [crate_name, in_dir.path, src.path, header.path],
        inputs = [in_dir],
        outputs = [src, header]
    )

    return src, header

UniffiSwiftInfo = provider("", fields = ["headers", "srcs"])

def _uniffi_files_impl(ctx):
    config = ctx.actions.declare_file("uniffi.toml")
    ctx.actions.write(output = config, content = """
[bindings.swift]
omit_argument_labels = true
generate_module_map = false
generate_immutable_records = true
experimental_sendable_value_types = true
""")

    out_dir = ctx.actions.declare_directory("out")
    generate_src_action(
        actions = ctx.actions, 
        tool = ctx.executable._uniffi, 
        config = config, 
        rust_lib = ctx.file.shared_lib, 
        language = "swift", 
        out_dir = out_dir
    )

    srcs = {}
    headers = {}
    for name in ctx.attr.uniffi_crates:
        src, header = _process_dir(ctx.actions, name, out_dir)
        srcs[name] = src
        headers[name] = header
    

    return UniffiSwiftInfo(headers = headers, srcs = srcs)

def _uniffi_headers_impl(ctx):
    info = ctx.attr.files[UniffiSwiftInfo]
    header = info.headers[ctx.attr.crate_name]

    return DefaultInfo(files = depset([header]))

def _uniffi_srcs_impl(ctx):
    info = ctx.attr.files[UniffiSwiftInfo]
    src = info.srcs[ctx.attr.crate_name]

    return DefaultInfo(files = depset([src]))


_uniffi_files = rule(
    implementation = _uniffi_files_impl,
    attrs = {
        "shared_lib": attr.label(allow_single_file = True, providers = [CcInfo]),
        "_uniffi": attr.label(default = Label("//tools:uniffi_bindgen"), executable = True, cfg = "host"),
        "uniffi_crates": attr.string_list(default = [])
    }
)

_uniffi_headers = rule(
    implementation = _uniffi_headers_impl,
    attrs = {
        "crate_name": attr.string(),
        "files": attr.label(providers = [UniffiSwiftInfo])
    }
)

_uniffi_srcs = rule(
    implementation = _uniffi_srcs_impl,
    attrs = {
        "crate_name": attr.string(),
        "files": attr.label(providers = [UniffiSwiftInfo])
    }
)

def uniffi_swift_library(*, name, library, uniffi_crates = []):
    native.cc_binary(
        name = "_%s-static" % name,
        deps = [library],
        linkshared = True,
        linkstatic = True,
    )

    _uniffi_files(
        name = "_%s-files" % name,
        shared_lib = "_%s-static" % name,
        uniffi_crates = uniffi_crates
    )

    swift_library_group(
        name = name,
        deps = ["_%s-module" % name for name in uniffi_crates] + ["_%s-lib" % name for name in uniffi_crates]
    )

    for crate_name in uniffi_crates:
        _uniffi_headers(
            name = "_%s-headers" % crate_name,
            crate_name = crate_name,
            files = "_%s-files" % name
        )
    
        _uniffi_srcs(
            name = "_%s-srcs" % crate_name,
            crate_name = crate_name,
            files = "_%s-files" % name
        )

        swift_library(
            name = "_%s-module" % crate_name,
            srcs = ["_%s-srcs" % crate_name],
            private_deps = ["_%s-lib" % name for name in uniffi_crates],
            module_name = derive_swift_module_name("", crate_name),
            linkstatic = True
        )

        swift_interop_hint(
            name = "_%s-interop-hint" % crate_name,
            module_name = derive_swift_module_name("", crate_name) + "FFI",
        )

        native.cc_library(
            name = "_%s-lib" % crate_name,
            hdrs = ["_%s-headers" % crate_name],
            deps = [library],
            aspect_hints = ["_%s-interop-hint" % crate_name],
            linkstatic = True,
        )

    

    
