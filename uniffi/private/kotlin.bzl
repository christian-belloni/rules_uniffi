load(":providers.bzl", "UniffiInfo")
load("@rules_kotlin//kotlin:jvm.bzl", "kt_jvm_library")
load("@rules_uniffi//3rdparty:defs.bzl", "JVM_DEPS", "ANDROID_DEPS")

def _kotlin_source_impl(ctx):
    info = ctx.attr.library[UniffiInfo]
    return DefaultInfo(
        files = depset([info.kotlin_source])
    )

kotlin_source = rule(
    implementation = _kotlin_source_impl,
    attrs = {
        "library": attr.label(mandatory = True, providers = [UniffiInfo])
    }
)

def uniffi_kotlin_library(name, library, **kwargs):
    kotlin_source(
        name = "%s-kotlin-source" % name,
        library = library
    )
    kt_jvm_library(
        name = name,
        srcs = [":%s-kotlin-source" % name],
        data = ["%s-shared" % library],
        deps = JVM_DEPS,
        **kwargs
    )

def uniffi_android_library(name, library, **kwargs):
    kotlin_source(
        name = "%s-kotlin-source" % name,
        library = library
    )
    kt_jvm_library(
        name = name,
        srcs = [":%s-kotlin-source" % name],
        data = ["%s-shared" % library],
        deps = ANDROID_DEPS,
        **kwargs
    )
