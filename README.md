# HRMS Mobile App

Employee self-service application built with Flutter, feature-first pragmatic
Clean Architecture, Riverpod, and Dio. The original `IndexedStack` navigation
and visual presentation are intentionally preserved.

See [Architecture](docs/ARCHITECTURE.md) for dependency rules, data flow,
security guidance, testing requirements, and instructions for adding features.

## Getting started

```bash
cp .env.example .env
flutter pub get
flutter run
```

For Flutter Web, use compile-time configuration instead of loading the hidden
`.env` asset:

```bash
dart run tool/dev_cors_proxy.dart
```

Keep the proxy running, then use a second terminal:

```bash
flutter run -d chrome \
  --dart-define=BASE_URL=http://localhost:8085/api/v1 \
  --dart-define=CONNECT_TIMEOUT_MS=15000 \
  --dart-define=RECEIVE_TIMEOUT_MS=15000 \
  --dart-define=ENABLE_LOGGING=false
```

The proxy is localhost-only and intended only for development. Production must
configure CORS on the API/reverse proxy for the deployed frontend origin.

Quality checks:

```bash
flutter analyze
flutter test
```

Authentication and attendance use the configured HRMS API. Other modules keep
replaceable local adapters until their response schemas are finalized.

Authentication is connected to the HRMS reference API configured by
`BASE_URL`. The current development host uses HTTP; migrate it to HTTPS before
shipping a production build.

## Flutter resources

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
