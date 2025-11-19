def generate_src_action(*, actions, tool, config, rust_lib, language, out_dir):
    args = actions.args()
    args.add_all(["generate", "-l", language, "--library"])
    args.add(rust_lib)
    args.add("-n")
    args.add("-c")
    args.add(config)
    args.add("--out-dir")
    args.add(out_dir.path)
    
    actions.run(
        executable = tool,
        outputs = [out_dir],
        arguments = [args],
        inputs = [rust_lib, config],
        mnemonic = "UniffiGenerate",
        progress_message = "Generating bindings for %{input}"
    )
