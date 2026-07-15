# Gamblock AI — Flutter Client (Android & Windows)

Flutter protection-client prototype for Gamblock AI. It contains the UI,
group-code/recovery flows, platform bridges, and contracts for on-device
classification and native protection. See the capability notes below before
assuming a contract or native source file is wired end to end.

> The PKM proposal requires a locally trained/evaluated URL-rule + BoW +
> Logistic Regression artifact pipeline. The current runtime contract lives in
> `lib/core/platform/ai_inference_stub.dart` and is not wired.

## Run

```sh
cp .env.example .env
flutter pub get
flutter run                 # or: flutter run -d windows / -d <android-device>
```

The project pins Flutter `3.41.9` via `.fvmrc` and CI. Dart constraints live in
`pubspec.yaml`.

## Architecture (clean architecture, feature-first)

```
lib/
  main.dart                 # entry; loads .env, inits ApiClient + platform services
  app/                      # GamblockApp, router, shell
  core/
    config/app_config.dart  # env-driven config (single source of truth for URLs)
    auth/auth_state.dart    # AuthNotifier (auth data layer)
    network/                # ApiClient (Dio, base URL from .env) + ApiResponse envelope helpers
    platform/               # native bridges + on-device services (ai_inference_stub = model contract)
    theme/                  # colors, text, theme
    widgets/                # shared brand widgets, one per file + barrel
  features/<feature>/       # clean architecture per feature:
    domain/                 #   entities + abstract repository contracts (pure Dart)
    data/                   #   repository impls (Dio via ApiClient) + Riverpod providers
    presentation/           #   screens (1/screen) + widgets (1/widget)
```

Features: `auth`, `dashboard`, `onboarding`, `pattern_interrupt`, `protection`,
`recovery`, `settings`, `intro`. Presentation never calls Dio directly — it reads
a repository via a Riverpod provider. See `AGENTS.md` for the full rules.

## Configuration

Copy `.env.example` to `.env` and set `API_BASE_URL` for your target
(`http://10.0.2.2:8080` for the Android emulator, `http://localhost:8080` for
Windows). `.env` is gitignored and holds configuration only — never secrets.

### `core/platform/` — the protection layer

- `platform_bridge.dart` — MethodChannel `com.gamblock/protection` to the native
  Android Accessibility Service and Windows Service. All calls tolerate a
  missing native handler (current prototype behavior).
- `ai_inference_stub.dart` — **integration contract** for the on-device Logistic
  Regression model. Threshold 0.72 is an uncalibrated engineering baseline;
  its DOM-only contract is incomplete relative to proposal-required URL rules
  + DOM/BoW. It is not currently loaded or called by the app.
- `local_notification_scheduler.dart` — supporting daily reminder trigger. NOTE:
  in-process `Timer`; full reliability needs `flutter_local_notifications`.
- `offline_queue.dart` — supporting pending-request queue, flushes on reconnect.
- `asset_downloader.dart` — downloads Pattern Interrupt assets on first launch.

## Native

- Android: Accessibility Service target for protection/accountability per the
  proposal; real-device runtime evidence remains required.
- Windows: `windows/runner/gamblock_service.{h,cpp}` is a prototype for the
  LocalSystem service and authenticated loopback WebSocket. It is not included
  in the current runner CMake target, so the extension-to-service flow is not
  yet end-to-end active.

## Validate

```sh
./scripts/verify.sh
./scripts/verify-ai-context.sh
```

`verify.sh` runs `flutter analyze` only. Dependency installation, tests, and
Android/Windows builds run only when explicitly requested by the user.

`AGENTS.md` and `docs/ai/README.md` are self-contained contributor and AI
context for a standalone clone.
