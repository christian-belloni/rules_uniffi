use std::sync::Arc;

use my_multiplier::ForeignMultiplier;
use uniffi::{export, Object};

uniffi::setup_scaffolding!();

#[export]
pub fn multiply_artifact(left: i32, right: i32) -> i32 {
    my_multiplier::multiply(left, right)
}

#[export]
pub fn add(left: i32, right: i32) -> i32 {
    my_adder::add(left, right)
}

#[derive(Object)]
pub struct MyCalculator {
    foreign_multiplier: Arc<dyn ForeignMultiplier>,
}

#[export]
impl MyCalculator {
    #[uniffi::constructor]
    pub fn new(foreign_multiplier: Arc<dyn ForeignMultiplier>) -> Arc<Self> {
        Arc::new(Self { foreign_multiplier })
    }

    pub fn multiply(&self, left: i32, right: i32) -> i32 {
        self.foreign_multiplier.multiply(left, right)
    }

    pub fn add(&self, left: i32, right: i32) -> i32 {
        add(left, right)
    }
}
