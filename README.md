# Overview

rules\_uniffi provides an easy and powerful way to develop cross platform applications with ergonomic interop with swift and kotlin (and more languages on the way)

# Stability guarantees and disclaimers

This is the third re-write of the same library so we can't make any promises at this time but we're hopeful since 
rules_kotlin version 2.1.4 landed (which supports rules_android)

__We are in no any way, shape or form affiliated with the [uniffi](https://github.com/mozilla/uniffi-rs) project__, 

we chose this name only to reflect how much of their work is utilized in this repo, without them this library wouldn't exist.

# Features
 - Swift/Kotlin code generation powered by the [uniffi](https://github.com/mozilla/uniffi-rs) project
 - Automatic target definition for the generated code (cdylib for kotlin and staticlib for swift)

# Roadmap
 - [ ] support uniffi.toml configuration
 - [ ] support multiple crates
 - [ ] support C#

# Out of the scope of this repo
 - [ ] support UDL definition files

***

# Quickstart

## Rust dependencies
add the uniffi library to your Cargo.toml's dependencies

```toml
uniffi = { version = "0.29" } # look for the compatibility section to choose the version
```

## Rust code
src/lib.rs

```rust
uniffi::setup_scaffolding!();

#[uniffi::export]
pub fn add(left: u8, right: u8) -> u8 {
    left + right
}
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

bazel_dep(
    name = "rules_swift",
    version = "2.8.2", # or the latest version available
)

# Define your rust dependencies

crate = use_extension("@rules_rust//crate_universe:extensions.bzl", "crate")

crate.from_cargo(
    name = "crates", # crates is what we will call this repository, feel free to change this 
                     # but afterwards we'll assume you used crates as the name
    # Replace this with the path to your  workspace Cargo.lock
    cargo_lockfile = "//:Cargo.lock", 
    # Replace this with the path to your workspace Cargo.toml and all your crate's Cargo.toml
    manifests = ["//:Cargo.toml"], 
)

use_repo(crate, "crates") # same as before

```

## The main library definition

Define your main library target, for more resources look at the [official rules\_rust docs](https://github.com/bazelbuild/rules_rust)

```starlark
# Load the entry point rule
load("@rules_uniffi//uniffi:defs.bzl", "uniffi_rust_library")

# Load your rust dependencies
load("@crates//:defs.bzl", "all_crate_deps")

uniffi_rust_library(
    # WARNING! for the moment this target name has to be the same as the package
    # defined in the Cargo.toml, in the future we'll relax this restriction.
    name = "my-library",
    cargo_toml = ":Cargo.toml",
    deps = all_crate_deps(),
    proc_macro_deps = all_crate_deps(proc_macro = True),
    srcs = glob(["src/**/*.rs"])
)

```

You'll see three targets defined by this rule,

 - the main "my-library" target, this is what we'll use for code generation
 - the static "my-library-static" target, this will be used for swift interop
 - the cdylib "my-library-shared" target, this will be used for kotlin interop

##

## The kotlin library definition

in a BUILD file define your kotlin generated library

```starlark
load("@rules_uniffi//uniffi:defs.bzl", "uniffi_kotlin_library")

uniffi_kotlin_library(
    name = "my-kotlin-library",
    library = ":my-library" # replace this with your library target
)

```

> To define an android kotlin library change "uniffi\_kotlin\_library" to "uniffi\_android\_library"

## The swift library definition

in a BUILD file define your kotlin generated library

```starlark
load("@rules_uniffi//uniffi:defs.bzl", "uniffi_swift_library")

uniffi_swift_library(
    name = "my-swift-library",
    library = ":my-library" # replace this with your library target
    module_name = "MyLibrary" # here you can modify the generated module name
)

```

## Conclusion

And we're done! 

**you can now reference "my-swift-library" as a swift dependency** and everything is wired up to compile,

you can find your functions, traits and structs in the module "MyLibrary"

**you can now reference "my-kotlin-library" as a kotlin dependency** and everything is wired up to compile,

for the moment it's not possible to change the full package path of the generated library, 

you can find your functions, traits and structs in the package uniffi.my\_library

