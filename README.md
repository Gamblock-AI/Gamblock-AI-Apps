# Gamblock AI — Flutter Protection Client

Android and Windows client for local gambling-content protection, Pattern
Interrupt, social accountability, and privacy-safe protection analytics.

The current result is a **code-complete prototype**. It includes the product
flows and native runtime wiring, but it is not yet a trained/evaluated AI model
or a release-readiness claim. Android real-device validation, Windows signed-VM
validation, accessibility review, performance profiling, and model evaluation
remain required.

## Run

```sh
cp .env.example .env
flutter pub get
flutter run
```

Flutter `3.41.9` is pinned through `.fvmrc` and CI. Configure
`API_BASE_URL` and `WEB_BASE_URL` in `.env`; the file contains public client
configuration only and is never committed.

## Product surfaces

The app uses four predictable top-level destinations:

- **Protection** — truthful native health, setup, self-test, approval grants,
  and device-bound emergency recovery.
- **Analytics** — 7/30-day aggregate counters only; no site timeline, URL,
  title, DOM, or inferred risk score.
- **Partner** — consented relationship lifecycle, invitations, request status,
  and history.
- **Settings** — account/password, locale, haptics, health notifications,
  pairing, artifact versions, privacy/help, and logout.

The native Pattern Interrupt runs for seven seconds, respects reduced motion,
works offline with a grounding option, and hands off to the website with only
locale and `source=pattern_interrupt`. The longer recovery journey remains on
the website and is not duplicated in Flutter.

## Hybrid-v1 dummy model

`assets/protection/` contains the versioned synthetic prototype:

- `dummy-rules-v1.json` — strong and medium URL rules;
- `dummy-lr-v1.json` — synthetic Bag-of-Words Logistic Regression weights;
- `hybrid-v1-fixtures.json` — deterministic allow/block fixtures;
- `manifest.json` — contract and SHA-256 integrity metadata.

Both Android and Windows implement the same bounded fusion policy:

1. normalize and bound supported URL/title/heading/anchor inputs;
2. evaluate URL rules;
3. count BoW tokens with a maximum contribution of three per token;
4. compute the Logistic Regression sigmoid;
5. block on a strong rule, model threshold `0.72`, or the documented hybrid
   combination.

The artifact is explicitly marked `trained: false` and `evaluated: false`.
Replace it only through a governed dataset/training/evaluation workflow.

## Android runtime

The Accessibility Service is declared in the active manifest and supports:

- Chrome (`com.android.chrome`) and Edge
  (`com.microsoft.emmx`) URL/title/headings/anchor extraction;
- bounded, debounced, single-threaded local classification;
- local Back navigation plus an accessibility overlay Pattern Interrupt;
- settings/uninstall friction tied to bounded approval or emergency grants;
- AES-GCM Android Keystore protection for local grants;
- daily allowlisted aggregate counters and last-known-good artifact loading;
- optional low-priority protection-health notification.

Other browsers and arbitrary Android WebViews are not claimed as covered. A
sideloaded app cannot make itself impossible to uninstall; the prototype adds
OS-supported friction and transparent recovery rather than unsafe device-owner
or critical-process behavior.

## Windows runtime

The Windows build contains two native processes:

- `gamblock_ai_service.exe` — LocalSystem SCM service with normal recovery,
  authenticated `127.0.0.1:9090` WebSocket, Hybrid-v1 classification,
  machine-DPAPI pairing/grants, and aggregate counters;
- `gamblock_ai_apps.exe` — user-session Flutter agent that connects through a
  logon-SID-restricted named pipe, performs supported `SendInput` navigation,
  presents Pattern Interrupt, and surfaces native state through Method/Event
  Channels.

The browser extension remains a passive sensor. It never receives a block
command. Install/uninstall scripts are under `windows/scripts/`; uninstall
requires an active approved removal or emergency grant. Windows runtime and
signing still require validation on a Windows VM/device.

The Windows service is split by responsibility under `windows/service/`:
runtime/SCM lifecycle, WebSocket handling, named-pipe commands, local state,
artifact updates, user-agent launch, and small platform support modules. The
Flutter runner similarly uses `native_protection_*.{cpp,h}` modules for codec,
channels, pipe transport, events, and settings monitoring. This keeps IPC,
credential storage, and update logic independently reviewable. Pipe operations
are cancellable during shutdown, and the Windows service joins its socket
workers before Winsock teardown.

## Backend contracts

The client uses:

- device registration/upsert by stable client instance ID;
- profile and password update;
- group membership workspace, code preview/join, and membership-bound approval
  request APIs;
- one-time approval application to a specific device;
- user-created, device-bound emergency requests reviewed by two distinct
  platform administrators;
- daily aggregate event sync and 7/30-day aggregate analytics.

Raw browsing inputs never enter these APIs.

## Validate

```sh
./scripts/verify.sh
./scripts/verify-ai-context.sh
```

`verify.sh` runs `flutter analyze`. Unit tests and platform builds are explicit
checks. The portable Windows Hybrid-v1 fixture can also be compiled directly
from `windows/protection/hybrid_classifier_test.cpp`.

Tag CI requires real Android keystore secrets and a Windows code-signing PFX;
release jobs do not fall back to debug signing.
