load(":providers.bzl", "UniffiInfo")
load("@rules_swift//swift:swift.bzl", "swift_library", "swift_interop_hint")

def _swift_source_impl(ctx):
    info = ctx.attr.library[UniffiInfo]
    return DefaultInfo( files = depset([info.swift_source]) )

swift_source = rule(
    implementation = _swift_source_impl,
    attrs = {
        "library": attr.label(mandatory = True, providers = [UniffiInfo])
    }
)

def _module_map_impl(ctx):
    info = ctx.attr.library[UniffiInfo]
    return DefaultInfo( files = depset([info.module_map]) )

module_map = rule(
    implementation = _module_map_impl,
    attrs = {
        "library": attr.label(mandatory = True, providers = [UniffiInfo])
    }
)

def _swift_c_header_impl(ctx):
    info = ctx.attr.library[UniffiInfo]
    return DefaultInfo( files = depset([info.c_header]) )

swift_c_header = rule(
    implementation = _swift_c_header_impl,
    attrs = {
        "library": attr.label(mandatory = True, providers = [UniffiInfo])
    }
)


def uniffi_swift_library(name, library, module_name = None):
    
    module_map(
        name = "%s-swift-module-map" % name,
        library = library,
    )
    
    swift_interop_hint(
        name = "%s-swift-interop-hint" % name,
        module_name = "%sFFI" % name,
        module_map = ":%s-swift-module-map" % name,
    )
    
    swift_c_header(
        name = "%s-hdrs" % name,
        library = library,
    )

    native.cc_import(
        name = "%s-shim" % name,
        static_library = "%s-static" % library,
        hdrs = [":%s-hdrs" % name],
        aspect_hints = ["%s-swift-interop-hint" % name],
    )

    swift_source(
        name = "%s-swift-source" % name,
        library = library,
    )

    swift_library(
        name = name,
        srcs = [":%s-swift-source" % name],
        deps = [":%s-shim" % name],
        module_name = module_name,
    )
