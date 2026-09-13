# Neurogine Product Catalog

A Flutter mobile technical assessment using the DummyJSON API.

## Current progress

Milestone 1: Android/iOS scaffold, dependencies, and a minimal Material 3 app.
Product listing, API integration, and other assessment features are not implemented yet.

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
before submission. This section will be updated as development continues.
