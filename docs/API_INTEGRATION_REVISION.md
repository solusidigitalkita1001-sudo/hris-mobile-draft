# HRMS Mobile API Integration Revision

## Scope

This revision prepares the Flutter application for the API documented in
`API-DOCS-FULL.md` without changing the existing UI. Integration is deliberately
incremental: authentication and attendance are connected first; modules whose
response schemas are not documented remain on replaceable local adapters.

## Implemented foundation

### Standard API contract

- `ApiEnvelope` parses the shared `success`, `message`, `data`, and `meta`
  response structure.
- Dio errors are normalized into `ApiException`, including HTTP status, backend
  error code, and validation errors per field.
- Infrastructure errors are mapped into typed failures: authentication,
  forbidden, validation, rate limit, network, and server failure.

### Session security

The secure session now stores:

- access and refresh tokens;
- token expiry duration;
- user and employee IDs;
- active company and company scope;
- group ID;
- roles and permissions;
- `mustChangePassword`;
- display name and email.

Sensitive values remain in Keychain/Keystore through
`flutter_secure_storage`. They are not stored in SharedPreferences.

### Refresh-token policy

Protected requests receive `Authorization: Bearer <accessToken>` automatically.
On HTTP 401, the interceptor:

1. starts or joins one shared refresh operation;
2. calls `POST /auth/refresh` with the refresh token;
3. stores the returned tokens;
4. retries the original request exactly once;
5. clears the session and invalidates the auth gate if refresh fails.

The single-flight behavior prevents concurrent 401 responses from generating
multiple refresh requests.

## Authentication flow

The temporary local login bypass has been removed. The flow is now:

1. validate email and password without changing the login layout;
2. call `POST /auth/login`;
3. parse and securely store the complete session;
4. create the shared employee/company request context;
5. show the existing Home shell;
6. on a subsequent launch, restore the session and validate it through
   `GET /auth/me`;
7. on sign-out, attempt `POST /auth/logout`, then always clear local data.

Network logout failure never leaves credentials on the device.

## Multi-company context

`requestContextProvider` is the single runtime source for `userId`,
`employeeId`, active `companyId`, and `companyScope`. The initial active company
uses `user.companyId`, falling back to the first scoped company. Selection is
validated so a company outside the user's scope cannot be activated.

A visual company selector is not added in this revision because changing the UI
was outside scope. The context is ready for that selector later.

## Attendance integration

Attendance now uses the production Dio adapter:

- `GET /attendance` for today's employee record;
- `POST /attendance` for check-in;
- `PATCH /attendance/{id}/checkout` for check-out.

`employeeId` and `companyId` come from the authenticated request context, not
hard-coded presentation values. DTO parsing accepts the documented camelCase
contract and legacy snake_case keys defensively. The existing Attendance screen
and interactions are unchanged.

## Dynamic Home and Profile data

After authentication, the existing Home layout is populated from live data:

- employee name, email, and identity context from the authenticated session;
- complete employee detail from `GET /employees/{employeeId}`;
- leave cards from `GET /leave/balances/employee`;
- attendance KPIs from `GET /attendance/summary`;
- today's clock status from `GET /attendance`;
- announcements projection from the three newest `GET /notifications` items.

These independent Home requests are loaded in parallel. A failed optional
endpoint does not erase valid data from another endpoint. Demo identity,
balances, and announcements are not displayed once an authenticated context is
available. Pull-to-refresh uses the same API projection without changing the UI.

Payroll values, assets, and certification counts remain outside this dynamic
projection because no corresponding mobile endpoint or response schema is
present in the supplied API reference. They must not be treated as verified
server data until those contracts are provided.

## Modules intentionally still local

Dashboard, Profile, Leave/Self-Service, Calendar, Notifications, Loans, and
Travel Expenses are not switched to production DTOs yet. The supplied API
reference lists their endpoints and request bodies, but generally does not
define the actual successful `data` schemas. Guessing those models would create
an unstable contract and runtime cast failures.

To integrate each remaining module safely, provide either:

- the source OpenAPI schema containing response models; or
- one sanitized successful response for every endpoint consumed by the mobile
  UI.

Recommended next order after schemas are available:

1. Profile (`GET /auth/me` and employee detail);
2. Leave requests and balances;
3. Work calendar and holidays;
4. Notifications;
5. Dashboard aggregation;
6. Loans, trips, and expense claims.

## Backend contract warnings

- Production must use HTTPS; the current HTTP host exposes credentials and
  bearer tokens in transit.
- `POST /employee-loans` has a documented validator/controller mismatch.
- Working days must temporarily send the calendar ID in both path and query.
- Employee attachment upload transport is not documented.
- `mustChangePassword=true` is stored, but a change-password screen still needs
  a product-approved UI before navigation can enforce it.

## Quality gates

Run before merging:

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

Repository and architecture tests continue to protect the Clean Architecture
dependency boundaries.
