use uniffi::export;
uniffi::setup_scaffolding!();

#[export]
pub fn multiply(left: i32, right: i32) -> i32 {
    left * right
}

#[export(with_foreign)]
pub trait ForeignMultiplier: Send + Sync + 'static {
    fn multiply(&self, left: i32, right: i32) -> i32;
}
