# Gamblock AI — Flutter Protection Client

Android and Windows client for local gambling-content protection, Pattern
Interrupt, social accountability, and privacy-safe protection analytics.

The current result is a **code-complete prototype**. It includes the local
protection flows and native runtime wiring. Detailed rehabilitation remains on
the website so this client stays small and focused. A supplied trained model is integrated, but
its reported metrics are not yet reproducible evaluation evidence or a
release-readiness claim. Android real-device validation, Windows signed-VM
validation, accessibility review, performance profiling, and model evaluation
remain required.

## Run

```sh
cp .env.example .env
flutter pub get
flutter run
```

Flutter `3.41.9` is pinned through `.fvmrc` and CI. Configure
`API_BASE_URL`, `WEB_BASE_URL`, `GOOGLE_WEB_CLIENT_ID`, and
`GOOGLE_WINDOWS_CLIENT_ID` in `.env`; the file contains public client
configuration only and is never committed. Android also requires the OAuth
client signing/SHA registration in Google Cloud. Never place an OAuth client
secret in the app.

## Product surfaces

The app uses four predictable top-level destinations:

- **Dashboard** — truthful native health, optional setup, self-test, approval grants,
  and device-bound emergency recovery.
- **Analytics** — 7/30-day aggregate counters only; no site timeline, URL,
  title, DOM, or inferred risk score.
- **Partner** — consented relationship lifecycle, invitations, request status,
  aggregate-sharing consent, normal/unsafe exit, cancellation, and history.
- **Settings** — account/password, locale, haptics, health notifications,
  pairing, artifact versions, privacy/help, and logout.

The brand typeface Plus Jakarta Sans (OFL) is bundled offline under
`assets/fonts/` and registered in `pubspec.yaml`; the app never downloads
fonts at runtime.

The native Pattern Interrupt runs for seven seconds, respects reduced motion,
works offline with a grounding option, and hands off to the website with only
locale and `source=pattern_interrupt`. The longer recovery journey remains on
the website and is not duplicated in Flutter. Android's optional daily
check-in reminder is local-only; Windows treats notification scheduling as a
no-op.

## Hybrid-v2 local model

`assets/protection/` contains the versioned portable runtime artifacts:

- `gamblock-lr-v2.json` — exact float32 Bag-of-Words, URL scaler, and Logistic
  Regression coefficients exported from the supplied ONNX graph;
- `gamblock-rules-v2.json` — supplied gambling keywords and source hash;
- `hybrid-v2-fixtures.json` — deterministic allow/block fixtures;
- `manifest.json` — contract and SHA-256 integrity metadata.

`scripts/export_onnx_linear_model.py` performs the reproducible conversion with
the system protobuf compiler and never loads the unsafe pickle artifact. Both
Android and Windows implement the same bounded fusion policy:

```sh
python3 scripts/export_onnx_linear_model.py \
  --onnx ../models/gamblock_logistic_regression.onnx \
  --metadata ../models/gamblock_hybrid_metadata.json \
  --keywords ../models/gambling_keywords.json \
  --model-output assets/protection/gamblock-lr-v2.json \
  --rules-output assets/protection/gamblock-rules-v2.json
```

1. normalize and bound supported URL/title/heading/anchor inputs;
2. compute the 14 ordered URL features and keyword rule locally;
3. count the exported 5,664 unigrams and 4,336 bigrams;
4. apply the exported StandardScaler values and Logistic Regression sigmoid;
5. compute `0.75 × model_probability + 0.25 × rule_score` and block at `0.4`.

The artifact is marked `trained: true` and `evaluated: false`. Its supplied
accuracy/precision/recall/F1 values are retained only as unverified metadata:
the dataset card, split manifest, training source, FPR slices, and preprocessing
parity evidence are still missing. Replace it only through the governed
dataset/training/evaluation workflow.

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
  authenticated `127.0.0.1:9090` WebSocket, Hybrid-v2 classification,
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
  administrators;
- daily aggregate event sync and 7/30-day aggregate analytics.

Raw browsing inputs never enter these APIs.

Authentication starts with a persisted three-step onboarding, then
login/register, then `/dashboard`. Password recovery uses a non-enumerating
email request and a single-use 12-character code. Android Google sign-in uses
the official provider plugin; Windows opens the installed-app OAuth flow in the
system browser and validates loopback state, nonce, and PKCE before sending
only the ID token to the backend. Provider access/refresh tokens are discarded.
The client remains `user`-only. If an admin-provisioned student signs in with a
temporary password, the login screen completes the required first-password
change before accepting the normal access/refresh session.

## Validate

```sh
./scripts/verify.sh
./scripts/verify-ai-context.sh
```

`verify.sh` runs `flutter analyze`. Unit tests and platform builds are explicit
checks. The portable Windows Hybrid-v2 fixture can also be compiled directly
from `windows/protection/hybrid_classifier_test.cpp`.

Every successful `main` commit force-updates one mutable `latest` GitHub
release. It replaces fixed-name development Android/Windows debug assets and
separate `production-debug` assets. The latter use
`APP_ENV=production`, `https://api.gamblock-ai.com`, and
`https://gamblock-ai.com`, so they remain usable for production integration
before signing material exists. Concurrent older runs are cancelled so the
newest commit wins.

Signed production Android and Windows jobs remain disabled until
`ENABLE_PRODUCTION_RELEASE=true` and the real Android keystore and Windows
code-signing PFX secrets exist. They do not silently fall back to debug
signing; production-config debug assets stay explicitly labeled debug.
