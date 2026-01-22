UniffiSwiftInfo = provider(doc = "", fields = {
  "static_library": "Static library",
  "module_name": "Module name",
  "hdrs": "Headers",
  "srcs": "Swift sources",
})

UniffiKotlinInfo = provider(doc = "", fields = {
  "shared_library": "Shared library",
  "srcs": "Kotlin sources",
})

UniffiDepInfo = provider(doc = "", fields = {
  "main_crate": "Main crate",
  "deps": "Dependencies"
})
