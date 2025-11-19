def _compile_java_jar_impl(ctx):
    jar = ctx.actions.declare_file("lib%s.jar" % ctx.attr.name)
    moved = ctx.actions.declare_file("java/" + ctx.file.library.basename)

    ctx.actions.run_shell(
        command = "cp {} {}".format(ctx.file.library.path, moved.path),
        inputs = [ctx.file.library],
        outputs = [moved]
    )
    
    return [DefaultInfo(files = depset([jar])), java_common.compile(
        ctx = ctx,
        output = jar,
        java_toolchain = ctx.attr._toolchain[java_common.JavaToolchainInfo],
        resources = [moved],
    )]

compile_java_jar = rule(
    implementation = _compile_java_jar_impl,
    attrs = {
        "library": attr.label(allow_single_file = True, providers = [CcInfo]),
        "_toolchain": attr.label(default = "@bazel_tools//tools/jdk:current_java_toolchain")
    },
    fragments = ["java"],
    toolchains = ["@bazel_tools//tools/jdk:toolchain_type"]
)
