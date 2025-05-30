use std::{
    path::{Path, PathBuf},
};

pub fn main() {
    let cargo_path = PathBuf::from(std::env::var("CARGO_TOML").unwrap());

    // awful hack to circumvent path resolution in bazel
    if !Path::new("./Cargo.toml").exists() {
        std::fs::write(
            "./Cargo.toml",
            format!(
                r#"[workspace]
resolver="3"
members = ["{}"]"#,
                cargo_path.parent().unwrap().display()
            ),
        )
        .unwrap();
    }

    uniffi::uniffi_bindgen_main();

    if std::env::var("LANG").is_ok_and(|val| val == "kotlin") {
        let base_path = PathBuf::from(std::env::var("OUT_DIR").unwrap());
        let lib_name = std::env::var("LIB_NAME").unwrap();

        let destination = base_path.join(format!("{lib_name}.kt"));
        let source = base_path
            .join("uniffi")
            .join(&lib_name)
            .join(format!("{lib_name}.kt"));

        std::fs::create_dir_all(destination.parent().unwrap()).unwrap();

        println!("{}\n{}", source.display(), destination.display());

        std::fs::copy(&source, &destination).unwrap();

        println!("{}", destination.display());

        std::fs::remove_dir_all(base_path.join("uniffi")).unwrap();
    }
}
