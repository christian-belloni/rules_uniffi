use uniffi::export;

uniffi::setup_scaffolding!("crate_2");

crate_1::uniffi_reexport_scaffolding!();

#[export]
pub fn my_nested_add(left: u8, right: u8) -> u8 {
    left + right
}
