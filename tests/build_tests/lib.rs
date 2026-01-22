use uniffi::export;

uniffi::setup_scaffolding!();

#[export]
pub fn my_function(left: i32, right: i32) -> i32 {
    left + right
}
