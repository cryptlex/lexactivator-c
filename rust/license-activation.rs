use std::io::{self, BufRead}; // for user input (pause)

use lexactivator::{
    LexActivatorCode, LexActivatorError, LexActivatorStatus, PermissionFlags,
};

fn init() {
    let product_data: String = "Product.dat_content".to_string();
    let product_id: String = "Product_id".to_string();

    let mut result: Result<(), LexActivatorError> = lexactivator::set_product_data(product_data);
    println!("SetProductData: {:?}", result);

    result = lexactivator::set_product_id(product_id, PermissionFlags::LA_USER);
    println!("SetProductId: {:?}", result);
}

fn activate() {
    let license_key: String = "License_key".to_string();

    let result: Result<(), LexActivatorError> = lexactivator::set_license_key(license_key);
    println!("SetLicenseKey: {:?}", result);

    let activation_result: Result<LexActivatorStatus, LexActivatorError> =
        lexactivator::activate_license();
    match activation_result {
        Ok(LexActivatorStatus::LA_OK) => {
            println!("License activated successfully");
        }
        Ok(_) => {
            println!("License activation not successful");
        }

        Err(error) => {
            println!("License activation failed: {:?}", error);
        }
    }
}

fn main() {
    init();
    activate();

    let callback_result: Result<(), LexActivatorError> =
        lexactivator::set_license_callback(|code| match code {
            LexActivatorCode::Status(status) => match status {
                LexActivatorStatus::LA_OK => println!("License is active!"),
                LexActivatorStatus::LA_EXPIRED => println!("License has expired!"),
                LexActivatorStatus::LA_SUSPENDED => println!("License has been suspended!"),
                LexActivatorStatus::LA_GRACE_PERIOD_OVER => {
                    println!("License grace period is over!")
                }
                _ => println!("Unknown license status"),
            },
            LexActivatorCode::Error(error) => match error {
                LexActivatorError::LA_E_ACTIVATION_NOT_FOUND => {
                    println!("The license activation was deleted on the server.")
                }
                _ => println!("Error: {}", error),
            },
        });
    println!("SetLicenseCallback: {:?}", callback_result);

    let validation_result: Result<LexActivatorStatus, LexActivatorError> =
        lexactivator::is_license_genuine();
    match validation_result {
        Ok(LexActivatorStatus::LA_OK) => {}
        Ok(_) => {
            println!("License is not genuine");
        }
        Err(error) => {
            println!("License validation failed: {:?}", error);
        }
    }

    println!("Program paused.");
    let stdin = io::stdin();
    let _ = stdin.lock().lines().next();

}
