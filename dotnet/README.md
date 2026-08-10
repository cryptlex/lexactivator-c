# LexActivator .NET Example

Example demonstrating license activation with **Cryptlex.LexActivator**, the .NET binding
for the LexActivator licensing library.

## Supported platforms

- .NET Framework 4.5+
- .NET Standard 1.1+

This directory contains several samples:

- [csharp-dotnet-core](csharp-dotnet-core) — C# console sample targeting .NET Core
- [csharp-dotnet-45](csharp-dotnet-45) — C# WinForms sample targeting .NET Framework 4.5
- [vb-dotnet-45](vb-dotnet-45) — VB.NET WinForms sample targeting .NET Framework 4.5

## Running

The [`Cryptlex.LexActivator`](https://www.nuget.org/packages/Cryptlex.LexActivator)
NuGet package is restored automatically on build. Edit the sample's `Program.cs`
(or `Form`) and replace the placeholder `product_data`, `product_id`, and `license_key`
values with the ones from your Cryptlex dashboard, then build and run, e.g.:

```bash
dotnet run --project csharp-dotnet-core
```

## Documentation

Refer to the following for documentation:

https://cryptlex.com/docs/sdks-and-apis/lexactivator
