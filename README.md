# Neurogine Product Catalog

A Flutter mobile technical assessment using the DummyJSON API.

## Current progress

Milestone 2: Dio configuration, product models, and remote data source for
listing, paginated server-side search, and fresh product details are implemented.
The UI still shows the milestone 1 welcome screen. Repository, controller,
and product screens will be added in later milestones.

## Getting started

Created with Flutter 3.29.3 and Dart 3.7.2.

```sh
flutter pub get
flutter run
flutter analyze
```

Use an Android emulator or connected Android device. Building for iOS requires
macOS and Xcode. Unit tests will be added in the testing milestone.

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
remote data source, and Android network permission change.

## Data layer decisions

- Dio is injected into the remote data source, allowing reuse and test replacement.
- Requests use a 15-second connection and receive timeout.
- Search uses the server endpoint so results include products beyond loaded pages.
- Pagination metadata comes from the API; total is not hardcoded.
- Brand is nullable; missing images use an empty list and thumbnail an empty string.
- Required product fields are parsed strictly. Invalid data and HTTP failures
  propagate to the caller instead of being disguised as an empty result.
- Repository/controller error messages and request race handling are deferred
  to their respective milestones.

API reference: https://dummyjson.com/docs/products
