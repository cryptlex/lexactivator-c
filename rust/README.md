# LexActivator Rust Example

Example demonstrating license activation with the [LexActivator Rust SDK](https://crates.io/crates/lexactivator).

## Running

```bash
cargo run --manifest-path rust/Cargo.toml --example license-activation
```

Before running, edit [license-activation.rs](license-activation.rs) and replace the
placeholder `product_data`, `product_id`, and `license_key` values with the ones
from your Cryptlex dashboard.

The `lexactivator` crate downloads the native LexActivator library for your platform
automatically during the build, so no manual setup is required.
