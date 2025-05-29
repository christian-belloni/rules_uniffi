use std::path::PathBuf;

pub fn main() {
    // let wrapper: PathBuf = std::env::var("CARGO_WRAPPER").unwrap().into();
    // println!(
    //     "using wrapper at {} {}",
    //     wrapper.display(),
    //     wrapper.exists()
    // );
    // unsafe {
    //     std::env::set_var(
    //         "PATH",
    //         wrapper.parent().unwrap().to_string_lossy().to_string(),
    //     );
    // };

    uniffi::uniffi_bindgen_main();

    if std::env::var("LANG").is_ok_and(|val| val == "kotlin") {
        let base_path = PathBuf::from(std::env::var("OUT_DIR").unwrap());
        let lib_name = std::env::var("LIB_NAME").unwrap();

        let destination = base_path.join(format!("{lib_name}.kt"));
        let source = base_path
            .join("uniffi")
            .join(&lib_name)
            .join(format!("{lib_name}.kt"));

        std::fs::copy(&source, &destination).unwrap();

        println!("{}", destination.display());

        std::fs::remove_dir_all(base_path.join("uniffi")).unwrap();
    }
}
