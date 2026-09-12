# HRMS Mobile Architecture

## Status

The application uses **feature-first, pragmatic Clean Architecture** with
Riverpod for state management and dependency injection. Attendance, dashboard,
authentication, profile, self-service, and calendar each own their domain contract, data
adapter, repository implementation, provider wiring, and controller.
Authentication and attendance now use production API adapters; modules without
documented response schemas retain replaceable local/demo adapters.

## Goals

- Keep business rules independent from Flutter, HTTP, and storage packages.
- Let features evolve without importing another feature's data layer.
- Make network, storage, location, and time replaceable in tests.
- Treat attendance and approvals as server-confirmed transactions.
- Avoid unnecessary use-case classes for presentation-only state.

## Project layout

```text
lib/
├── main.dart                       # composition root + unchanged UI shell
├── app/
│   └── providers/              # app-wide theme/session state
├── core/
│   ├── config/                 # public runtime configuration
│   ├── errors/                 # Failure and Result
│   ├── network/                # Dio and API exception mapping
│   ├── security/               # Keychain/Keystore token storage
│   ├── services/               # location and clock abstractions
│   ├── storage/                # non-sensitive preferences
│   ├── theme/
│   └── widgets/                # feature-independent UI primitives
└── features/
    └── <feature>/
        ├── <feature>_dependencies.dart # concrete DI wiring
        ├── <feature>_providers.dart    # public presentation providers
        ├── domain/
        │   ├── entities/
        │   ├── repositories/
        │   └── usecases/
        ├── data/
        │   ├── datasources/
        │   ├── dto/
        │   └── repositories/
        └── presentation/
            ├── controllers/
            ├── models/
            ├── screens/
            └── widgets/
```

## Dependency rules

```text
presentation ──► domain ◄── data
      │                    │
      └────── app/core ─────┘
```

1. Domain is pure Dart. It must not import Flutter, Riverpod, Dio, a data
   layer, or a presentation layer.
2. Data implements domain repository contracts and maps DTOs to entities.
3. Presentation reads Riverpod controllers/use cases, never Dio or a remote
   datasource directly.
4. Core must not import any feature.
5. Features do not import another feature. Cross-feature orchestration belongs
   in the app layer through explicit contracts.
6. DTOs do not extend domain entities. Mapping is explicit with `toEntity()`.

These rules are guarded by `test/architecture/dependency_rules_test.dart`.

## Module flows

```text
AttendanceScreen
  → AttendanceController (AsyncNotifier)
  → ClockIn / ClockOut use case
  → AttendanceRepository (domain contract)
  → AttendanceRepositoryImpl
  → AttendanceRemoteDataSource
  → AttendanceDto.toEntity()
```

Expected business failures are returned as `Result<T>`. Datasources may throw
infrastructure exceptions; repositories translate them into domain-safe
`Failure` values. The controller exposes loading/data/error through
`AsyncValue`.

The other modules follow the same dependency direction:

- Authentication: `LoginScreen → AuthController → Login → AuthRepository → Dio`.
- Dashboard: `HomeScreen → DashboardController → DashboardRepository`.
- Profile: `ProfileScreen → ProfileController → ProfileRepository`.
- Self-service: `RequestsScreen → RequestController → SubmitRequest → RequestRepository`.
- Calendar: `CalendarScreen → CalendarController → CalendarRepository`.

Local widget state remains valid for tabs, animation, selection, and other
ephemeral presentation concerns. Repository-backed data never lives in a
screen.

## Application foundation

- `main.dart` is the single composition root. It initializes public runtime
  configuration and preferences before creating `ProviderScope`.
- The original `MaterialApp`, `IndexedStack`, and bottom navigation remain in
  `main.dart` to preserve the existing UI exactly.
- Theme state is a Riverpod notifier persisted in SharedPreferences.
- Authentication tokens are stored with `flutter_secure_storage`, not Hive or
  SharedPreferences.
- Dio obtains public configuration through an overridden provider, adds the
  current access token, refreshes an expired token once, and retries the failed
  request once. Network logging is debug-only and disabled by default.
- Clock and location are injectable services so use cases remain testable.

## Configuration and secrets

Copy `.env.example` to `.env`, then pass it with
`--dart-define-from-file=.env`. The file is not an application asset. Compile-
time values are still public and extractable from an application binary, so the
allowable keys are limited to environment, API base URL, timeouts, and the
non-sensitive logging flag. Never store API secrets, passwords, private keys,
tokens, cookies, or permanent service credentials in it.

Development may use the documented HTTP endpoint. Release and profile builds
are treated as production: `BASE_URL` is mandatory, must use HTTPS, and network
logging must be disabled. Invalid values fail startup with an `AppConfigException`
that names the setting and correction.

For local Web development, `tool/dev_cors_proxy.dart` provides a loopback-only
proxy when the remote API does not allow localhost origins. Point `BASE_URL` to
`http://localhost:8085/api/v1`. This proxy is never a production CORS solution;
the deployed API or Nginx must allow the actual production frontend origin.

Production tokens belong in Keychain/Keystore through `TokenStorage`. Optional
debug network logs contain only a request sequence, HTTP method, status/error
category, and duration. They never inspect the URL, headers, query, body,
response payload, or exception message.

Android permits cleartext only through the debug manifest. iOS uses a dedicated
debug Info.plist for the domain-specific ATS exception; profile and release use
the main plist without an exception. The current reference server remains an
HTTP development dependency and must be replaced by an HTTPS endpoint for a
production build.

## Adding a feature

1. Model business language in `domain/entities` with typed dates, enums, and
   nullable values where appropriate.
2. Define a repository interface in domain.
3. Add a use case only when the operation contains policy, validation,
   orchestration, authorization, or reuse. Simple reads may call a repository
   from the controller.
4. Define DTOs and explicit mappers under data.
5. Implement remote/local datasources and translate their exceptions in the
   repository implementation.
6. Wire concrete dependencies in `<feature>_dependencies.dart`; expose only
   controller providers from `<feature>_providers.dart` to screens.
7. Render `AsyncValue` states in the screen. Keep temporary animation/tab
   state local to the widget.
8. Add domain, repository, controller, widget, and critical integration tests.

## Offline policy

- Profile, dashboard, announcement: cache then refresh.
- Attendance history and calendar: show cached data while refreshing.
- Clock-in/out: online-required unless the backend explicitly supports signed,
  idempotent pending operations.
- Leave request: drafts may be local; submission is only confirmed by server.

Never show a sensitive operation as successful before receiving server
confirmation. If offline transactions are later required, use explicit states:

```text
draft → pendingSync → syncing → confirmed | rejected
```

## Testing and quality gates

Run before merging:

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

The test suite enforces core independence, pure domain layers, feature
isolation, and the absence of presentation-to-data imports. It also covers all
current repositories and the unchanged application shell. New business rules must have unit tests; login,
clock-in/out, leave submission, approval, and logout should eventually receive
integration tests against a staging backend.

## Production adapters still required

The architecture is wired, but these integrations require backend contracts
and platform credentials before release:

- Replace `DemoLocationService` with a permission-aware Geolocator adapter.
- Add encrypted/cache retention policies appropriate to employee data.
- Configure Firebase, notification permissions, camera/location usage strings,
  production application IDs, and release signing.
- Replace dashboard, profile, self-service, and calendar demo/local datasources
  with API/cache adapters as their contracts become available.

These are deployment integrations, not reasons to bypass the layer boundaries.
