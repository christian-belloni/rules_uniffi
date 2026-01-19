load("@rules_kotlin//kotlin:jvm.bzl", "kt_jvm_library")
load("@rules_kotlin//kotlin:android.bzl", "kt_android_library")
load("@rules_rust//rust:rust_common.bzl", "CrateInfo", "DepInfo")
load("@rules_rust//rust:rust_shared_library.bzl", "rust_shared_library")
load("@rules_rust//rust:rust_static_library.bzl", "rust_static_library")
load("@rules_cc//cc:cc_shared_library.bzl", "cc_shared_library")
load("@rules_cc//cc:cc_library.bzl", "cc_library")
load("@rules_cc//cc:cc_binary.bzl", "cc_binary")
load("@rules_cc//cc:cc_import.bzl", "cc_import")
load("@rules_android//rules:rules.bzl", "android_library")

load(":common.bzl", "generate_src_action")
load(":utils.bzl", _compile_java_jar = "compile_java_jar")


KOTLIN_CONFIGURATION_TEMPLATE = """
[bindings.kotlin]
generate_immutable_records = {generate_immutable_records}
android = {android}
android_cleaner = {android_cleaner}
"""


def _collect_kotlin_srcs(*, ctx, srcs_dir, src_out):
    args = ctx.actions.args()
    args.add_all(depset(srcs_dir))

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




def _extract_sources(ctx, rust_lib, configuration):
    config = ctx.actions.declare_file("%s/uniffi.toml" % ctx.label.name)
    
    generate_immutable_records = "true" if configuration.generate_immutable_records else "false"
    android = "true" if configuration.android else "false"
    android_cleaner = "true" if configuration.android_cleaner else "false"

    ctx.actions.write(
        output = config,
        content = KOTLIN_CONFIGURATION_TEMPLATE
            .replace("{generate_immutable_records}", generate_immutable_records)
            .replace("{android}", android)
            .replace("{android_cleaner}", android_cleaner)
    )
    
    out_dir = ctx.actions.declare_directory("_out_%s" % ctx.label.name)

    generate_src_action(
        actions = ctx.actions,
        tool = ctx.executable._uniffi,
        config = config,
        language = "kotlin",
        rust_lib = rust_lib,
        out_dir = out_dir
    )

    return out_dir

def _uniffi_kotlin_library_impl(ctx):
    crate_info = ctx.file.shared_library
    srcs = _extract_sources(ctx, crate_info, struct(generate_immutable_records = ctx.attr.generate_immutable_records, android = ctx.attr.android, android_cleaner = ctx.attr.android_cleaner))

    src = ctx.actions.declare_file("_%s_source.kt" % ctx.attr.name)
    _collect_kotlin_srcs(
        ctx = ctx,
        srcs_dir = [srcs],
        src_out = src
    )
    deps = ctx.attr.library[DepInfo].direct_crates
    parsed_srcs = []

    for i, dep in enumerate(deps.to_list()):
        dep_deps =  dep.dep.deps.to_list()
        dep_names = [name.crate_info.name for name in dep_deps if name.crate_info != None]
        uniffi_names = [ name for name in dep_names if name.find("uniffi") != -1 ]
        if len(uniffi_names) == 0:
            print("found unused")
        else:
            print("found used, {}".format(len(uniffi_names)))

        src = ctx.actions.declare_file("{}_{}_src.kt".format(dep.name, i))
        ctx.actions.run_shell(
            command = """
            cp {0}/uniffi/{1}/*.kt {2} 2>/dev/null || touch {2}
            """.format(srcs.path, dep.name, src.path),
            inputs = [srcs],
            outputs = [src]
        )
        parsed_srcs.append(src)

    src = ctx.actions.declare_file("%s_src.kt" % ctx.attr.library[CrateInfo].name)
    ctx.actions.run_shell(
        command = """
        cp {0}/uniffi/{1}/*.kt {2} 2>/dev/null || touch {2}
        """.format(srcs.path, ctx.attr.library[CrateInfo].name, src.path),
        inputs = [srcs],
        outputs = [src]
    )
    parsed_srcs.append(src)

    return [ DefaultInfo(files = depset(parsed_srcs)), ctx.attr.library[CcInfo] ]


_uniffi_kotlin_library = rule(
    implementation = _uniffi_kotlin_library_impl,
    attrs = {
        "library": attr.label(providers = [CrateInfo]),
        "shared_library": attr.label(allow_single_file = True),
        "generate_immutable_records": attr.bool(default = False),
        "android": attr.bool(default = False),
        "android_cleaner": attr.bool(default = False),
        "_uniffi": attr.label(default = Label("//tools:uniffi_bindgen"), executable = True, cfg = "host"),
    }
)


def uniffi_android_library(*, name, library, generate_immutable_records = False, package_name = "uniffi"):
    shared_name = "_%s_android" % Label(library).name.replace("-", "_")
    cc_binary(
        name = shared_name,
        deps = [library],
        linkshared = True,
        visibility = ["//visibility:public"],
    )

    _uniffi_kotlin_library(
        name = "_%s_android_inner" % name,
        library = library,
        shared_library = shared_name,
        generate_immutable_records = generate_immutable_records,
        android = True,
        android_cleaner = True
    )

    cc_library(
      name = "%s_jni_shim" % name,
      srcs = ["@rules_uniffi//tools:android_link_hack.c"],  # Required because of https://github.com/bazelbuild/rules_rust/issues/1271
      linkopts = [
          "-lm",  # Required to avoid dlopen runtime failures unrelated to rust
      ],
      deps = [library],
      alwayslink = True,  # Required since JNI symbols appear to be unused
    )

    android_library(
        name = "_%s_android_compiled" % name,
        exports  = ["%s_jni_shim" % name],
    )

    kt_android_library(
        name = name,
        srcs = [":_%s_android_inner" % name],
        deps = ["@rules_uniffi//tools:jna", "_%s_android_compiled" % name],
    )


def uniffi_kotlin_library(*, name, library, generate_immutable_records = False):
    shared_name = "_%s_kotlin" % Label(library).name.replace("-", "_")
    cc_binary(
        name = shared_name,
        deps = [library],
        linkshared = True,
        visibility = ["//visibility:public"],
    )

    _uniffi_kotlin_library(
        name = "_%s_kotlin_inner" % name,
        library = library,
        shared_library = shared_name,
        generate_immutable_records = generate_immutable_records,
    )

    _compile_java_jar(
        name = "_%s_kotlin_compiled" % name,
        library = shared_name
    )

    kt_jvm_library(
        name = name,
        srcs = [":_%s_kotlin_inner" % name],
        deps = ["@rules_uniffi//tools:jna", "_%s_kotlin_compiled" % name],
    )





