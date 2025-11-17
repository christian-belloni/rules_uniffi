use uniffi::export;

uniffi::setup_scaffolding!();

#[export]
pub fn add(left: u8, right: u8) -> u8 {
    left + right
}
