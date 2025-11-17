load("@rules_rust//rust:rust_common.bzl", "CrateInfo", "DepInfo")
load("@rules_rust//rust:defs.bzl", "rust_common")
load("@rules_swift//swift:providers.bzl", "SwiftInfo", "create_swift_module_context", "create_clang_module_inputs", "create_swift_module_inputs")
load("@rules_swift//swift:swift_common.bzl", "swift_common")
load("@rules_swift//doc:doc.bzl", "derive_swift_module_name")

def _uniffi_library_impl(ctx):
    rust = ctx.attr.rust_library
    shared = _cc_providers(ctx.attr.shared_library)
    static = _cc_providers(ctx.attr.static_library)

    return _rust_providers(rust) + [UniffiInfo(rust_library = rust, shared_library = shared, static_library = static)]


def _cc_providers(cc_dep):
    default_info = cc_dep[DefaultInfo]
    cc_info = cc_dep[CcInfo]
    return [default_info, cc_info]
    

def _rust_providers(rust):
    default_info = rust[DefaultInfo]
    crate_info = rust[CrateInfo]
    dep_info = rust[DepInfo]
    return [default_info, crate_info, dep_info]

UniffiInfo = provider("", fields = {
    "rust_library": "Rust library",
    "shared_library": "Rust shared library",
    "static_library": "Rust static library"
})


uniffi_library = rule(
    implementation = _uniffi_library_impl,
    attrs = {
        "rust_library": attr.label(providers = [CrateInfo, DefaultInfo]),
        "shared_library": attr.label(providers = [DefaultInfo, CcInfo]),
        "static_library": attr.label(providers = [DefaultInfo, CcInfo]),
    },
)

def _tmp_shared_impl(ctx):
    info = ctx.attr.uniffi_library[UniffiInfo]
    default_info = info.shared_library[0]
    cc_info = info.shared_library[1]
    return [default_info, cc_info]

#    out_dir = ctx.actions.declare_directory("%s_swift_out" % ctx.attr.name)
#    ctx.actions.run(inputs = [cdylib], outputs = [out_dir], executable = ctx.executable._uniffi, arguments = ["generate", "--language", "swift", "--library", cdylib.path, "--out-dir", out_dir.path])
#
#    swift_file = ctx.actions.declare_file("%s.swift" % ctx.attr.name)
#
#    ctx.actions.run_shell(inputs = [out_dir], outputs = [swift_file], command = "cp {0}/{1}.swift {2}".format(out_dir.path, ctx.attr.name, swift_file.path))

def _uniffi_swift_library_impl(ctx):

    ccinfo = ctx.attr.uniffi_library[UniffiInfo].static_library[1]
    # ccinfo = ctx.attr.uniffi_library[UniffiInfo].static_library[CcInfo]


    cdylib = ctx.attr.uniffi_library[UniffiInfo].static_library[0].files.to_list()[0]
    out_dir = ctx.actions.declare_directory("_generated_%s" % ctx.attr.name)



    ctx.actions.run(inputs = [cdylib], outputs = [out_dir], executable = ctx.executable._uniffi, arguments = ["generate", "--language", "swift", "--library", cdylib.path, "--out-dir", out_dir.path])

    swift_file = ctx.actions.declare_file("%s.swift" % ctx.attr.name)
    ctx.actions.run_shell(inputs = [out_dir], outputs = [swift_file], command = "cp {}/*.swift {}".format(out_dir.path, swift_file.path))
    
    header_file = ctx.actions.declare_file("%s.h" % ctx.attr.name)
    ctx.actions.run_shell(inputs = [out_dir], outputs = [header_file], command = "cp {}/*FFI.h {}".format(out_dir.path, header_file.path))

    modulemap_file = ctx.actions.declare_file("%s.modulemap" % ctx.attr.name)
    ctx.actions.run_shell(inputs = [out_dir], outputs = [modulemap_file], command = "cp {}/*FFI.modulemap {}".format(out_dir.path, modulemap_file.path))
    
    comp_ctx = cc_common.create_compilation_context(headers = depset([header_file]))

    swift_toolchain = swift_common.get_toolchain(ctx)

    feature_configuration = swift_common.configure_features(
        ctx = ctx,
        requested_features = [],
        swift_toolchain = swift_toolchain,
        unsupported_features = [],
    )
    

    precompiled = swift_common.precompile_clang_module(
        actions = ctx.actions,
        cc_compilation_context = comp_ctx,
        feature_configuration = feature_configuration,
        module_map_file = modulemap_file,
        module_name = derive_swift_module_name("", ctx.attr.name),
        swift_toolchain = swift_toolchain,
        target_name = ctx.attr.name,
        toolchain_type = None
    )

    clang_module = create_clang_module_inputs(compilation_context = comp_ctx, module_map = modulemap_file, precompiled_module = precompiled)
    
    compilation_context = swift_common.create_compilation_context(defines = [], srcs = [swift_file], transitive_modules = [])

    module_context = create_swift_module_context(name = ctx.attr.name, clang = clang_module, compilation_context = compilation_context)

    compiled = swift_common.compile(
        actions = ctx.actions,
        cc_infos = [ccinfo],
        feature_configuration = feature_configuration,
        module_name = derive_swift_module_name("", ctx.attr.name),
        package_name = None,
        srcs = [swift_file],
        swift_infos = [SwiftInfo(modules = [clang_module])],
        swift_toolchain = swift_toolchain,
        target_name = ctx.attr.name,
        workspace_name = ctx.workspace_name,
    )

    

    return [DefaultInfo(files = depset(compiled.compilation_outputs.objects)), compiled.swift_info]


uniffi_swift_library = rule(
    implementation = _uniffi_swift_library_impl,
    provides = [SwiftInfo],
    attrs = {
        "uniffi_library": attr.label(providers = [UniffiInfo]),
        "_uniffi": attr.label(default = Label("//tools:uniffi_bindgen"), executable = True, cfg = "host")
    },
    fragments = ["cpp"],
    toolchains = swift_common.use_toolchain(),
)

tmp_shared = rule(
    implementation = _tmp_shared_impl,
    attrs = {
        "uniffi_library": attr.label(providers = [UniffiInfo])
    },
)
