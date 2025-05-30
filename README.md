# Overview

rules\_uniffi provides an easy and powerful way to develop cross platform applications with ergonomic interop with swift and kotlin (and more languages on the way)

# Features
 - Swift/Kotlin code generation powered by the [uniffi](https://github.com/mozilla/uniffi-rs) library
 - Automatic target definition for the generated code (cdylib for kotlin and staticlib for swift)

# Kotlin Quickstart

## Rust dependencies

add the uniffi library to your Cargo.toml's dependencies

```toml
uniffi = { version = "0.29" } # look for the compatibility section to choose the version
```

## MODULE.bazel

Add all the necessary dependencies to your `MODULE.bazel`

```starlark
bazel_dep(
    name = "rules_uniffi",
)

# TODO! replace this with the actual release
local_path_override(
    module_name = "rules_uniffi",
    path = "../.."
)

bazel_dep(
    name = "rules_rust",
    version = "0.61.0" # or the latest version available
)


bazel_dep(
    name = "rules_kotlin", 
    version = "2.1.4" # or the latest version available
)

# Define your rust dependencies

crate = use_extension("@rules_rust//crate_universe:extensions.bzl", "crate")

crate.from_cargo(
    name = "crates", # crates is what we will call this repository, feel free to change this but afterwards we'll assume you used crates as the name
    cargo_lockfile = "//:Cargo.lock", # Replace this with the path to your  workspace Cargo.lock
    manifests = ["//:Cargo.toml"], # Replace this with the path to your  workspace Cargo.toml
)

use_repo(crate, "crates") # same as before

```
