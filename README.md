# Gamblock AI — Flutter Client (Android & Windows)

Lightweight protection client for Gamblock AI. It runs the on-device AI
classifier, executes blocking + Pattern Interrupt, manages group-code linking,
and keeps the Windows Service / Android Accessibility Service alive.

> The AI model is a separate artifact (PRD §1.3). The runtime integration
> contract lives in `lib/core/platform/ai_inference_stub.dart`.

## Run

```sh
flutter pub get
flutter run                 # or: flutter run -d windows / -d <android-device>
```

Minimum: Flutter 3.8 / Dart 3.8 (see `pubspec.yaml`).

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
  missing native handler (PRD §3.2).
- `ai_inference_stub.dart` — **integration contract** for the on-device Logistic
  Regression model. Threshold 0.72; input = DOM text; output = probability.
  Replace the bodies of `loadModel`/`classify` only.
- `local_notification_scheduler.dart` — daily reminder trigger (PRD §7.2). NOTE:
  in-process `Timer`; full reliability needs `flutter_local_notifications`.
- `offline_queue.dart` — pending-request queue, flushes on reconnect (PRD §6.3).
- `asset_downloader.dart` — downloads Pattern Interrupt assets on first launch.

## Native

- Android: Accessibility Service for anti-uninstall (PRD §3.2).
- Windows: `windows/runner/gamblock_service.{h,cpp}` — LocalSystem service,
  auto-restart hardening, process + window-title monitoring, and the
  authenticated WebSocket server (port 9090) for the browser extension.

See the root `AGENTS.md` for the end-to-end architecture and PRD alignment.
