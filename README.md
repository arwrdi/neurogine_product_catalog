# Neurogine Product Catalog

A Flutter mobile technical assessment using the DummyJSON API.

## Current progress

Milestone 4: ProductController manages loading, pagination, refresh, query reset,
and retry through ProductRepository. Controller tests cover failures and stale
responses. The UI still shows the milestone 1 welcome screen; Provider wiring,
product screens, and search debounce will be added in later milestones.

## Getting started

Created with Flutter 3.29.3 and Dart 3.7.2.
Milestone 4 was tested with Flutter 3.35.4, matching the current local package
configuration. Use the same Flutter installation for dependency resolution,
analysis, and tests; mixing SDK installations causes compilation errors.

```sh
flutter pub get
flutter run
flutter analyze
flutter test
```

Use an Android emulator or connected Android device. Building for iOS requires
macOS and Xcode. Controller tests run without network access. Model mapping tests
will be added in the model testing milestone.

## Initial decisions

- `main.dart` starts the app; `app.dart` owns application configuration and theme.
- Subsequent milestones will use feature-first data and presentation layers.
- Dio will handle HTTP, Provider with ChangeNotifier will manage state, and
  cached_network_image will provide image caching and placeholders.
- No code generation or additional runtime packages are planned.

## AI usage

AI assistance generated the initial scaffold setup, dependency configuration,
base app code, and this documentation. This is implementation assistance, beyond
guidance or research alone. The candidate will review and understand the code
before submission. AI also generated the milestone 2 API configuration, models,
remote data source, and Android network permission change, followed by the
milestone 3 repository and milestone 4 controller, tests, and documentation.

## Data layer decisions

- Dio is injected into the remote data source, allowing reuse and test replacement.
- Requests use a 15-second connection and receive timeout.
- Search uses the server endpoint so results include products beyond loaded pages.
- Pagination metadata comes from the API; total is not hardcoded.
- Brand is nullable; missing images use an empty list and thumbnail an empty string.
- Required product fields are parsed strictly. Invalid data and HTTP failures
  propagate to the caller instead of being disguised as an empty result.
- ProductRepository provides a small entry point for presentation controllers.
  Its remote data source is injected through the constructor; HTTP requests and
  JSON parsing stay in the data source and models. No separate domain layer,
  interface/implementation pair, cache, or service locator is needed at this size.
- The repository preserves pagination metadata and propagates failures unchanged.
  The controller maps failures to readable messages and uses a request version
  to ignore stale responses after refresh/search or disposal. Requests are not
  cancelled at the HTTP level. Pagination failures keep existing products and
  retry the same offset. Failed requests are not converted into empty pages.
- Controller state is exposed through read-only getters. Provider will own its
  lifecycle when the catalog screen is implemented. The search method resets
  pagination immediately; the search UI will supply the debounce later.

API reference: https://dummyjson.com/docs/products
