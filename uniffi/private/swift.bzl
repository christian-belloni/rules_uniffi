load("@rules_cc//cc:find_cc_toolchain.bzl", "use_cc_toolchain", "find_cc_toolchain")
load("@rules_cc//cc/common:cc_common.bzl", "cc_common")
load("@rules_cc//cc/common:cc_info.bzl", "CcInfo")
load("@rules_rust//rust:rust_common.bzl", "CrateInfo", "DepInfo")
load("@rules_swift//swift:swift_interop_info.bzl", "create_swift_interop_info")
load("@rules_swift//swift:swift_clang_module_aspect.bzl", "swift_clang_module_aspect")
load("@rules_swift//swift:swift_library.bzl", "swift_library")
load("@rules_swift//swift:module_name.bzl", "derive_swift_module_name")
load(":common.bzl", "generate_src_action")


SWIFT_CONFIGURATION_TEMPLATE = """
[bindings.swift]
omit_argument_labels = true
generate_module_map = false
generate_immutable_records = true
experimental_sendable_value_types = true
"""


def _extract_by_extension(*, actions, in_dir, out_dir, extension):
    actions.run_shell(
        command = """
        mkdir -p {0} && 
        if [ -f {1}/*.{2} ]; then
        cp {1}/*.{2} {0}/
        else
            touch {0}/_tmp.swift
        fi
        """.format(out_dir.path, in_dir.path, extension),
        inputs = [in_dir],
        outputs = [out_dir]
    )

def _collect_swift_srcs(*, ctx, srcs_dir, src_out, reimport = True):
    args = ctx.actions.args()
    args.add_all(depset(srcs_dir))

    if not reimport:
        ctx.actions.run_shell(
            command = """
            for f in $@
            do
                cat $f >> {0}
                echo '\n' >> {0}
            done
            """.format(src_out.path),
            arguments = [args],
            inputs = srcs_dir,
            outputs = [src_out]
        )
    else:
        ctx.actions.run_shell(
            command = """
            for f in $@
            do
                echo "import {1}FFI\n" >> {0}
                cat $f >> {0}
                echo '\n' >> {0}
            done
            """.format(src_out.path, derive_swift_module_name("", ctx.attr.library.label.name)),
            arguments = [args],
            inputs = srcs_dir,
            outputs = [src_out]
        )


def _extract_sources(ctx, crate_info):
    config = ctx.actions.declare_file("%s/uniffi.toml" % crate_info.name)
    ctx.actions.write(
        output = config,
        content = SWIFT_CONFIGURATION_TEMPLATE
    )

    rust_lib = crate_info.output
    out_dir = ctx.actions.declare_directory("_out_%s" % crate_info.name)

    generate_src_action(
        actions = ctx.actions,
        tool = ctx.executable._uniffi,
        config = config,
        language = "swift",
        rust_lib = rust_lib,
        out_dir = out_dir
    )

    out_sources = ctx.actions.declare_directory("_%s_out_srcs" % crate_info.name)
    _extract_by_extension(
        actions = ctx.actions,
        in_dir = out_dir,
        out_dir = out_sources,
        extension = "swift"
    )

    out_headers = ctx.actions.declare_directory("_%s_out_headers" % crate_info.name)
    _extract_by_extension(
        actions = ctx.actions,
        in_dir = out_dir,
        out_dir = out_headers,
        extension = "h"
    )

    return out_sources, out_headers


def _uniffi_swift_library_impl(ctx):
    cc_toolchain = find_cc_toolchain(ctx)
    feature_configuration = cc_common.configure_features(ctx = ctx, cc_toolchain = cc_toolchain)

    depinfo = ctx.attr.library[DepInfo].direct_crates
    
    dep_sources = []
    dep_headers = []

    for aliasable_dep in depinfo.to_list():
        dep = aliasable_dep.dep
        src, header = _extract_sources(ctx, dep)
        dep_headers.append(header)
        dep_sources.append(src)

    rust_lib = ctx.attr.library[CrateInfo]

    out_sources, out_headers = _extract_sources(ctx, rust_lib)

    dep_headers += [out_headers]

    ccinfo = ctx.attr.library[CcInfo]

    compilation_context, _ = cc_common.compile(
        name = ctx.attr.name,
        actions = ctx.actions,
        feature_configuration = feature_configuration,
        cc_toolchain = cc_toolchain,
        public_hdrs = [out_headers] + dep_headers,
        compilation_contexts = [ccinfo.compilation_context],
        srcs = [out_headers] + dep_headers
    )

    ccinfo = CcInfo(compilation_context = compilation_context, linking_context = ccinfo.linking_context)

    src_out = ctx.actions.declare_file("%s_srcs.swift" % ctx.attr.name)

    _collect_swift_srcs(
        ctx = ctx,
        srcs_dir = [out_sources],
        src_out = src_out
    )

    srcs_out = []

    for i, dep_src in enumerate(dep_sources):
        _src_out = ctx.actions.declare_file("{}_{}_srcs.swift".format(ctx.attr.name, i))

        _collect_swift_srcs(
            ctx = ctx,
            srcs_dir = [dep_src],
            src_out = _src_out,
            reimport = True
        )
        srcs_out.append(_src_out)
    
    interop = create_swift_interop_info(
        module_name = "%sFFI" % derive_swift_module_name("", ctx.attr.library.label.name),
    )

    return [interop, DefaultInfo(files = depset([src_out] + srcs_out)), ccinfo]


_uniffi_swift_library = rule(
    implementation = _uniffi_swift_library_impl,
    attrs = {
        "library": attr.label(providers = [CcInfo, CrateInfo], aspects = [swift_clang_module_aspect]),
        "_uniffi": attr.label(default = Label("//tools:uniffi_bindgen"), executable = True, cfg = "host")
    },
    fragments = ["cpp"],
    toolchains = use_cc_toolchain()
)

def uniffi_swift_library(*, name, library):
    _uniffi_swift_library(
        name = "_%s_inner" % name,
        library = library
    )

    swift_library(
        name = name,
        deps = ["_%s_inner" % name],
        srcs = ["_%s_inner" % name],
        module_name = derive_swift_module_name("", Label(library).name),
    )
