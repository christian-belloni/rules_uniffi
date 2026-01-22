load("@rules_kotlin//kotlin:android.bzl", "kt_android_library")
load("@rules_uniffi//uniffi:defs.bzl", "uniffi_android")

load("@rules_android//rules:rules.bzl", "android_binary")
load("@rules_kotlin//kotlin:core.bzl", "kt_compiler_plugin")


kt_compiler_plugin(
    name = "compose",
    id = "androidx.compose.compiler.plugins.kotlin",
    target_embedded_compiler = True,
    visibility = ["//visibility:public"],
    deps = [
        "@maven//:org_jetbrains_kotlin_kotlin_compose_compiler_plugin_embeddable",
    ],
)

kt_compiler_plugin(
    name = "kapt",
    compile_phase = True,
    id = "org.jetbrains.kotlin.kapt",
    stubs_phase = True,
    visibility = ["//visibility:public"],
    deps = [
        "@maven//:org_jetbrains_kotlin_kotlin_gradle_plugin",
    ],
)

kt_android_library(
  name = "android_lib",
  custom_package = "com.example.app",
  srcs = ["src/MainActivity.kt"],
  deps = [
        "@maven//:androidx_activity_activity_compose",
        "@maven//:androidx_appcompat_appcompat",
        "@maven//:androidx_compose_material_material",
        "@maven//:androidx_compose_runtime_runtime",
        "@maven//:androidx_compose_ui_ui",
        "@maven//:androidx_compose_ui_ui_tooling",
        "@maven//:androidx_core_core_ktx",
        "@maven//:com_google_guava_guava",

    ":my-lib"
  ],
  plugins = [":compose"]
)

uniffi_android(
  name = "my-lib",
  uniffi_library = "//rust:uniffi-lib",
  custom_package = "uniffi.my_artifact"
)

android_binary(
  name = "android_bin",
  custom_package = "com.example.app",
  deps = [":android_lib"],
  manifest = ":AndroidManifest.xml",
  dex_shards = 25,
)


