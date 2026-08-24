load("//uniffi/private:common.bzl", _uniffi_library = "uniffi_library")
load("//uniffi/private:swift.bzl", _uniffi_swift = "uniffi_swift")
load("//uniffi/private:kotlin.bzl", _uniffi_android = "uniffi_android", _uniffi_kotlin = "uniffi_kotlin")

uniffi_library = _uniffi_library
uniffi_swift = _uniffi_swift
uniffi_android = _uniffi_android
uniffi_kotlin = _uniffi_kotlin
