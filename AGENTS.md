# Gamblock-AI Flutter Client Agent Rules


This standalone repository contains the Android and Windows protection client.
Read `docs/ai/README.md` and `docs/ai/distribution-matrix.md` before changing
behavior or workflows; they distinguish working capabilities, distribution
variants, and target architecture.

## Non-negotiable boundaries

- All DOM/URL classification and blocking decisions happen on-device. Never
  send raw DOM, URLs, domains, screenshots, or browsing history to the backend.
- The browser extension is a passive sensor. The Android/Windows client owns
  classification, blocking, and Pattern Interrupt.
- Never use `RtlSetProcessIsCritical` or another critical-process mechanism.
  Windows hardening uses SCM recovery; Android uses Accessibility Service.
- The client may send aggregate events only. Journal/error catalog contracts
  must stay aligned with the backend and website.
- Blocked-event timestamps (when a block fired, device-local converted to UTC)
  may be included in the aggregate payload so the backend can run SPK
  time-pattern detection. Never send the URL, domain, DOM, or content that was
  blocked; timestamps are the only addition to the aggregate contract.
- `WEB_BASE_URL` is the only web-origin source for education and recovery
  handoffs. Pattern Interrupt may send only locale plus the fixed source
  category—never detected context.
- Offline aggregate rows contain only an allowlisted category, UTC date,
  bounded count, optional owned device ID, optional 24-slot hourly histogram
  (device-local hour, aggregate counts only), optional blocked-event timestamps
  (UTC), and deterministic idempotency key.

## Start and finish

1. Inspect `git status`; preserve unrelated user changes and deleted local
   helper scripts.
2. Copy `.env.example` to `.env` when setting up a fresh clone. `.env` contains
   public client configuration only and is never committed.
3. Read adjacent implementation/tests and identify whether the area is
   `implemented`, `stub`, `not wired`, or `planned`.
4. Keep one feature unit per change and follow the feature architecture below.
 5. Run `./scripts/verify.sh` (l10n merge check + Flutter analyze) before handoff and
   `./scripts/verify-ai-context.sh` when context changed. Do not run tests or
   builds unless the user explicitly requests them in the current conversation.

## Feature-first clean architecture

New or substantially changed features use:

```text
lib/features/<feature>/
  domain/          # pure Dart entities and repository contracts
  data/            # Dio implementations and shared Riverpod providers
  presentation/    # screens and widgets
```

- `domain/` has no Flutter, Dio, or platform dependency.
- `presentation/` never imports Dio or `ApiClient`; it consumes a domain
  repository through Riverpod.
- Shared repository providers belong in `data/providers.dart`.
- Some existing dashboard/protection/recovery providers still live in screen
  files. Treat this as known migration debt; do not copy that pattern into new
  features, and move it only when the affected feature is already in scope.
- Keep one widget per file, except a `StatefulWidget` and its private `State`.

## Shared infrastructure

- `lib/core/config/app_config.dart`: environment-driven URLs.
- `lib/core/network/api_client.dart`: the Dio singleton and auth envelope.
- `lib/core/network/api_response.dart`: response parsing helpers.
- `lib/core/auth/auth_state.dart`: authentication state and calls.
- `lib/core/platform/`: native bridges and protection-related contracts.
- `lib/core/messaging/app_messages.dart`: stable backend error-code mapping.
- `lib/core/theme/`: `AppColors`, `AppTheme`, `AppText`, and the
  `AppRadius`/`AppIconSize` scales in `app_dimens.dart`.
- `lib/core/widgets/`: shared brand widgets (`SurfaceCard`, `Pressable`,
  `SkeletonBox`, `EmptyState`, `AppSectionLabel`, and friends).
- `lib/core/feedback/`: `AppFeedback` snackbars and the global `Haptics` flag.
- `lib/core/device/`: device registry and aggregate sync helpers.
- `lib/core/settings/`: persisted app preferences (locale, haptics).

Do not hardcode URLs in features or call Dio from presentation code.

## Current native and AI status

- `assets/protection/` is a wired Hybrid-v2 artifact exported from the supplied
  ONNX graph. Android and Windows implement the same rule + unigram/bigram BoW
  + scaled URL-feature + Logistic Regression fusion contract. It is trained
  but not evaluated by project evidence; supplied metrics remain unverified.
- Android native source is wired through the active manifest and Method/Event
  Channels for Chrome/Edge sensing, classification, intervention, grant state,
  and aggregates. Real-device coverage, accessibility, lifecycle, and
  performance evidence are still required.
- Windows uses `windows/service/` for the LocalSystem authority and the
  small `windows/runner/native_protection_*.{cpp,h}` modules for the
  user-session agent.
  Source/CMake/MSI/release wiring is present; a Windows build and VM/device
  trace are still required before calling it runtime-verified.
- Any WebSocket shape change must be coordinated with the browser extension
  implementation/tests/README without moving blocking authority into it.

Existing UI/contracts do not by themselves satisfy the platform, AI, blocking,
interruption, or accountability requirements until wired and evidenced on the
active Android/Windows runtimes. The current handoff label is code-complete
prototype, not evaluated/release-ready.

## Messaging and interaction

- Add every stable backend error code to `AppMessages.forCode` and the website
  catalog. Use localized strings, not hardcoded screen messages. Never render
  Dio/backend technical text or error codes to users, including development.
- Use `AppFeedback` for action feedback and `Haptics` for meaningful tactile
  events. Snackbars remain dismissible; expected form rejections should stay
  inline and preserve entered values. Respect reduced motion and the global
  haptics flag.
- Use shared brand widgets for consistent loading, empty states, and presses.

## Validation policy

The repository pins Flutter `3.41.9` in `.fvmrc` and CI.

```sh
cp .env.example .env      # once per fresh clone
flutter pub get            # bootstrap/setup, when dependencies are absent
./scripts/verify.sh        # default AI check: l10n merge check + flutter analyze
./scripts/verify-ai-context.sh  # additionally when context changed

# l10n workflow (source of truth is lib/l10n/modules/<locale>/*.json):
python3 scripts/merge_l10n.py       # merge modules -> app_<locale>.arb
python3 scripts/merge_l10n.py --check  # validate parity only
flutter gen-l10n                    # regenerate Dart localization classes

# Explicit user request only:
flutter test
flutter build apk --debug
flutter build windows
```

Mirror `lib/` under `test/` when tests are in scope. Use `mocktail` for
repository tests and `flutter_test` for widgets. Never call real backend or
external services.

CI builds the `play` and `research` Android flavors, the Windows debug bundle,
and a diagnostic MSI without production keys. The CI diagnostic lane also
produces a `research`-flavor staging APK pointed at `api-staging.gamblock-ai.com`
(`STAGING_API_BASE_URL`/`STAGING_WEB_BASE_URL`), so test data stays in the
`gamblock_staging` database; a manual Research Staging GitHub Release
(`staging-release.yml`, `workflow_dispatch`) publishes that debug APK for QA.
Signed release builds are
restricted to immutable semantic-version tags and protected environments. See
`docs/ai/distribution-matrix.md` for the exact artifact and key contract.

## Protected and external actions

- Do not edit `.env`, credentials, keystores, generated build output, or
  platform dependency caches.
- CI debug artifacts are clearly labelled and short-retention; CI must not
  create or mutate a public `latest` release. The Research Staging release is a
  debug APK for QA/test only, is clearly labelled unsigned and staging-backed,
  and must never be presented as signed, store-ready, or production-ready.
  Tag-triggered candidates remain
  gated workflow artifacts: Play receives a signed AAB, the Research pilot a
  separately signed APK, and the Windows pilot a signed MSI only after the
  protected signing environments succeed. Never present a debug/unsigned
  artifact as signed or store a secret in client config.
- Do not deploy, publish, sign releases, push, or change secrets without
  explicit user authorization.
