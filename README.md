# Neurogine Product Catalog

A Flutter mobile technical assessment using the DummyJSON API.

## Current progress

Milestone 7: Server-side search now uses a 450 ms debounce with clear and keyboard
submit actions. Each new query resets pagination and scroll position. The search
field remains visible during loading, error, and empty states.
The catalog displays a two-column grid with loading, error, empty,
and pagination states. Tapping a product fetches fresh details and opens its
image gallery, description, price, discount, rating, brand, category, and stock.
Reusable cached images include loading/error placeholders (implemented early
in milestone 5). The pull-to-refresh gesture is still pending.
The controller already supports query resets and refresh.

## Getting started

Created with Flutter 3.29.3 and Dart 3.7.2.
Milestones 4–7 were tested with Flutter 3.35.4, matching the current local package
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
milestone 3 repository, milestone 4 controller/tests, milestone 5 catalog UI,
milestone 6 detail controller/page, and milestone 7 search/debounce, tests,
and documentation.

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
  lifecycle in the catalog screen. The search method resets
  pagination immediately after the search field's 450 ms debounce. Clearing or
  keyboard submission cancels the timer and runs immediately. Disposing the
  search field cancels its pending timer.

API reference: https://dummyjson.com/docs/products

## UI decisions and verification

- Provider owns the shared Dio, repository, and list controller. The detail route
  owns a separate controller so opening details preserves the catalog state.
- The detail controller handles requests and disposal; widgets contain no HTTP
  logic. The gallery uses a swipeable PageView and falls back to the thumbnail.
- Ten automated tests cover controller behavior and widget flows including
  list error/retry, fresh detail requests, detail error/retry, back navigation,
  empty results, debounce timing, clearing, keyboard submission, and disposal.
  Widget tests use fake data and no network.
- Manual device verification remains: scroll through multiple pages, open a
  product with multiple images, swipe its gallery, return to the same scroll
  position, and check layout with larger text. Android/iOS builds have not been
  verified in these milestones.

