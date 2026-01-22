load("@rules_rust//rust:defs.bzl", "rust_library", "rust_shared_library", "rust_static_library")

def uniffi_crate(*, name, **kwargs):
  rust_library(
    name = name,
    compile_data = kwargs.pop("compile_data", [":Cargo.toml"]),
    **kwargs
  )
  rust_shared_library(
    name = name + "_shared",
    crate_name = kwargs.pop("crate_name", name.replace("-", "_")),
    compile_data = kwargs.pop("compile_data", [":Cargo.toml"]),
    **kwargs
  )
  rust_static_library(
    name = name + "_static",
    crate_name = kwargs.pop("crate_name", name.replace("-", "_")),
    compile_data = kwargs.pop("compile_data", [":Cargo.toml"]),
    **kwargs
  )
