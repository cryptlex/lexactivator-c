# LexActivator Android Example

Example demonstrating license activation with the LexActivator Android licensing library.

## Running

Open the [sample](sample) project in Android Studio (or build it with the bundled
Gradle wrapper). Edit
[sample/app/src/main/java/com/cryptlex/sample/MainActivity.java](sample/app/src/main/java/com/cryptlex/sample/MainActivity.java)
and replace the placeholder `product_data`, `product_id`, and `license_key` values with
the ones from your Cryptlex dashboard, then build and run:

```bash
cd sample
./gradlew installDebug
```

The [`com.cryptlex.android.lexactivator`](https://search.maven.org/search?q=g:%22com.cryptlex.android.lexactivator%22%20AND%20a:%22lexactivator%22)
dependency is declared in the app's `build.gradle`.

## Documentation

Refer to the following for documentation:

https://cryptlex.com/docs/sdks-and-apis/lexactivator
