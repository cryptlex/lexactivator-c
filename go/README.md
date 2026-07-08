# LexActivator Go Example

Example demonstrating license activation with **lexactivator-go**, the Go wrapper for the
LexActivator licensing library.

## Installation

```bash
go get -u github.com/cryptlex/lexactivator-go
```

**Note:** On Windows, execute the following after installation:

```bash
xcopy %USERPROFILE%\go\src\github.com\cryptlex\lexactivator-go\libs\windows_amd64\LexActivator.dll
```

Then you can include it in your code:

```go
import "github.com/cryptlex/lexactivator-go"
```

## Running

Edit [sample.go](sample.go) and replace the placeholder `product_data`, `product_id`,
and `license_key` values with the ones from your Cryptlex dashboard, then run:

```bash
go run sample.go
```

## Documentation

Refer to the following for documentation:

https://docs.cryptlex.com/node-locked-licenses/using-lexactivator
