# LexActivator Python Example

Example demonstrating license activation with **cryptlex.lexactivator**, the Python
wrapper for the LexActivator licensing library.

## Installation

```bash
pip install cryptlex.lexactivator
```

Then you can include it in your code:

```python
from cryptlex.lexactivator import LexActivator, LexStatusCodes, PermissionFlags, LexActivatorException
```

## Running

Edit [sample.py](sample.py) and replace the placeholder `product_data`, `product_id`,
and `license_key` values with the ones from your Cryptlex dashboard, then run:

```bash
python sample.py
```

## Documentation

Refer to the following for documentation:

https://docs.cryptlex.com/node-locked-licenses/using-lexactivator
