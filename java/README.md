# LexActivator Java Example

Example demonstrating license activation with the LexActivator Java licensing library.

## Running

The example is a Maven project. Edit
[sample/src/main/java/com/cryptlex/sample/Sample.java](sample/src/main/java/com/cryptlex/sample/Sample.java)
and replace the placeholder `product_data`, `product_id`, and `license_key` values with
the ones from your Cryptlex dashboard, then run from the `sample` directory:

```bash
mvn compile exec:java
```

The [`com.cryptlex.lexactivator`](https://search.maven.org/search?q=g:%22com.cryptlex.lexactivator%22%20AND%20a:%22lexactivator%22)
dependency is declared in [sample/pom.xml](sample/pom.xml).

## Documentation

Refer to the following for documentation:

https://docs.cryptlex.com/node-locked-licenses/using-lexactivator
