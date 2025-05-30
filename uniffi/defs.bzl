load("//uniffi/private:uniffi.bzl", _uniffi_library = "uniffi_library", _uniffi_rust_library = "uniffi_rust_library")
load("//uniffi/private:swift.bzl", _uniffi_swift_library = "uniffi_swift_library")
load("//uniffi/private:kotlin.bzl", _uniffi_kotlin_library = "uniffi_kotlin_library")
load("//uniffi/private:kotlin.bzl", _uniffi_android_library = "uniffi_android_library")

uniffi_library = _uniffi_library
uniffi_rust_library = _uniffi_rust_library
uniffi_swift_library = _uniffi_swift_library
uniffi_kotlin_library = _uniffi_kotlin_library
uniffi_android_library = _uniffi_android_library
