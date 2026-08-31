# lexactivator-examples

Sample integrations showing how to add Cryptlex license activation and validation
to your application using **LexActivator**, across a range of languages and platforms.

## What is LexActivator?

LexActivator is Cryptlex's client library for licensing your software. You embed it
in your application to activate, validate, and manage licenses on your users' machines.
It communicates with the Cryptlex server (either the Cryptlex cloud or a self-hosted
on-premise instance) and supports:

- **Node-locked licenses** tied to a specific machine
- **Hosted floating licenses** managed on the Cryptlex server (cloud or on-premise)
- **Verified trials** validated against the Cryptlex server
- **Offline activation** for air-gapped machines
- License **features, metadata, and entitlements**

If you're adding licensing to an application, LexActivator is the library you start with.

> Need floating licenses served from within your own network, with no internet access
> on client machines? See [lexfloatclient-examples](https://github.com/cryptlex/lexfloatclient-examples), which
> uses [LexFloatClient](https://cryptlex.com/docs/sdks-and-apis/lexfloatclient) against an on-premise [LexFloatServer](https://cryptlex.com/docs/sdks-and-apis/lexfloatserver/overview).

## What's in this directory

Each subdirectory is a self-contained example for one language or platform and
includes its own README with setup, build, and run instructions: `c/` (C and
C++), `python/`, `js/` (Node.js), `go/`, `rust/`, `dotnet/` (C# and VB.NET),
`java/`, `android/`, `ios/`, `dart/` (Dart and Flutter), `ruby/`, `delphi/`,
and `matlab/`.

## Getting started

Clone just the example you need - a sparse checkout skips every other language:

```bash
git clone --filter=blob:none --sparse https://github.com/cryptlex/lexactivator-examples.git
cd lexactivator-examples
git sparse-checkout set js
```

## Getting started

1. Open the subdirectory for your language or platform.
2. Follow that directory's README for build and run steps.
3. Replace the placeholder product data / license key with your own values from the Cryptlex dashboard.

## Learn more

- Documentation: https://cryptlex.com/docs
- LexActivator reference: https://cryptlex.com/docs/sdks-and-apis/lexactivator