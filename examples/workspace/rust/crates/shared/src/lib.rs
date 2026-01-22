use uniffi::export;
uniffi::setup_scaffolding!();

#[export(with_foreign)]
pub trait Printer: Send + Sync + 'static {
    fn print_self(&self);
}
