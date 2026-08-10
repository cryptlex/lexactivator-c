# LexActivator Node.js Example

Example demonstrating license activation with **LexActivator.js**, the Node.js binding
for the LexActivator licensing library.

## Installation

```bash
npm install
```

This installs the [`@cryptlex/lexactivator`](https://www.npmjs.com/package/@cryptlex/lexactivator)
package declared in [package.json](package.json). You can then include it in your code:

```js
const { LexActivator, LexStatusCodes, LexActivatorException, PermissionFlags } = require('@cryptlex/lexactivator');
```

## Running

Edit [sample.js](sample.js) and replace the placeholder `product_data`, `product_id`,
and `license_key` values with the ones from your Cryptlex dashboard, then run:

```bash
node sample.js
```

## Documentation

Refer to the following for documentation:

https://cryptlex.com/docs/sdks-and-apis/lexactivator
