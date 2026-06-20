# Gamblock AI — Flutter Client Agent Rules

See the root `AGENTS.md` for the full architecture and PRD alignment. This file
covers conventions specific to the Flutter client.

## Clean architecture (feature-first, strict)

Every feature under `lib/features/<feature>/` follows three layers:

```
features/<feature>/
  domain/
    entities/        # plain model classes (e.g. DashboardSummary)
    repositories/    # abstract repository contracts (no Dio here)
  data/
    repositories/    # concrete impls that call ApiClient (Dio) via core/network
    providers.dart   # Riverpod providers for the repository (shared, one per feature)
  presentation/
    screens/         # one screen per file
    widgets/         # one widget per file
```

- `presentation/` MUST NOT import Dio or `ApiClient` directly. It depends on
  `domain/repositories` abstractions and reads them via Riverpod providers
  (`ref.read(xxxRepositoryProvider)`). All HTTP is isolated in `data/`.
- `domain/` has zero Flutter/Dio dependencies — pure Dart entities + contracts.
- Reusable Riverpod providers for a feature's repository live in
  `data/providers.dart` so multiple screens share one instance.

When adding a feature, mirror this layout. Add the entity in `domain/entities`,
the abstract contract in `domain/repositories`, the Dio impl in
`data/repositories`, a provider in `data/providers`, and screens/widgets in
`presentation/`.

## Shared infrastructure (`lib/core/`)

- `config/app_config.dart` — single source of truth for env-driven config
  (API base URL, asset base URL), read from `.env` via `flutter_dotenv`. Never
  hardcode URLs in features — read `AppConfig.apiBaseUrl` / `AppConfig.assetBaseUrl`.
- `network/api_client.dart` — Dio singleton; base URL from `AppConfig`. `init()`
  is idempotent and called from `main.dart` after `dotenv.load()`.
- `network/api_response.dart` — envelope unwrap helpers (`ApiResponse.map/list`).
  Feature data sources use these instead of hand-parsing `response.data['data']`.
- `platform/` — native bridges + on-device services (see `ai_inference_stub.dart`
  for the model integration contract; threshold 0.72).
- `widgets/` — shared brand widgets, one per file (`eyebrow_pill.dart`,
  `glass_card.dart`, `icon_chip.dart`, `brand_helpers.dart`). `brand_widgets.dart`
  is a barrel re-export for backward compatibility.

## One widget per file

Each file contains at most one widget class. The only exception is a
`StatefulWidget` paired with its private `State` subclass (the standard Flutter
pair). Any additional widget (cards, banners, dialogs, slides, tabs) goes in its
own file under `presentation/widgets/` (or `core/widgets/` for shared ones).

## State & networking

- Riverpod for state; Dio for HTTP. Do not introduce a second solution.
- `core/auth/auth_state.dart` (`AuthNotifier`) is the auth data layer — auth
  screens call it via `ref.read(authProvider.notifier)`, never Dio directly.
- `.env` holds configuration only (base URLs), NOT secrets — client-side env is
  not private. `.env` is gitignored; `.env.example` is committed as the template.

## Testing

- `flutter test`. Tests mirror `lib/` under `test/`. `mocktail` mocks Dio in
  data-repository tests; `flutter_test` widgets for UI primitives.
- `AppConfig` is test-safe: reads dotenv via a try/catch so it returns ''
  (and `isProduction` falls back to `kReleaseMode`) when `.env` isn't loaded.
- When adding an entity, add a `fromJson` test under `test/<feature>/domain/`.
  When adding a repository impl, add a mock-Dio test under `test/<feature>/data/`.

## Micro-interactions & messaging

- **Messages**: `lib/core/messaging/app_messages.dart` is the FE mirror of the
  backend `internal/i18n/messages.go` catalog. Resolve any thrown error to a
  production-safe string via `AppMessages.friendlyMessage(error)` — it reads the
  Dio envelope `error.code`/`error.message`. Do not hardcode error strings in
  screens. Throw/propagate Dio errors; let the helper decide friendly vs technical.
- **Env gate**: `AppConfig.isProduction` (APP_ENV in `.env` + `kReleaseMode`
  fallback) gates messages — production shows friendly text, dev shows technical
  detail. Default safe = production in release builds.
- **Feedback**: use `AppFeedback.success/error/info(context, msg)`
  (`lib/core/feedback/feedback.dart`) instead of raw `showSnackBar`. It applies
  brand styling + automatic haptics (success=medium, error=heavy).
- **Haptics**: `lib/core/feedback/haptics.dart` wraps `HapticFeedback` (no-op on
  desktop). Call `Haptics.selection/light/medium/heavy` at meaningful moments
  (nav, taps, submit, success, error). Respect the global `Haptics.enabled` flag.
- **Micro-interactions** (honour platform reduced-motion automatically):
  - `Pressable` (`lib/core/widgets/pressable.dart`) for tactile cards/buttons.
  - `SkeletonBox` for loading placeholders; `EmptyState` for empty lists.
  - Route transitions are fade+slide via the router `_fadeSlidePage` pageBuilder.
- Keep catalogs in sync across backend / Next.js / Flutter when adding error codes.

## Privacy (PRD §6.1)

- All inference is on-device. DOM text, URLs, page content never leave the device.
- Backend `PrivacyGuard` rejects browsing fields; mirror that — only aggregate
  data in network payloads.

## Windows native (`windows/runner/gamblock_service.{h,cpp}`)

- Do NOT mark the process critical (`RtlSetProcessIsCritical`) — it BSODs the
  machine. Anti-tamper is via SCM auto-restart (see `Install()`).
- The browser extension is a passive sensor; the service is the sole blocking
  authority. See the WebSocket contract in `gamblock_service.cpp`.
