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

## Distribution and CI versions

The Android `play` and `research` flavors and the Windows pilot have separate
capability and signing boundaries. Pull requests and `main` build diagnostic
artifacts without production keys; those artifacts remain short-retention CI
outputs and are not user-facing releases. A Research staging APK is also built
against `api-staging.gamblock-ai.com` so test data never mixes with the
production backend, and can be published on demand as a "Research Staging"
GitHub Release for QA. Signed Play/Research/Windows
candidates are built only from immutable version tags in protected GitHub
Environments. The complete matrix, key names, and artifact contract are in
[`docs/ai/distribution-matrix.md`](docs/ai/distribution-matrix.md).

## Run

```sh
cp .env.example .env
flutter pub get
flutter run --flavor play
```

Use `flutter run --flavor research` only on an approved research device.

Flutter `3.41.9` is pinned through `.fvmrc` and CI. Configure
`API_BASE_URL` and `WEB_BASE_URL` in `.env`; the file contains public client
configuration only and is never committed. Never place a client secret in the
app.

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
the website and is not duplicated in Flutter. The opt-in daily check-in
reminder works on Android (repeating daily schedule) and Windows (one-shot
toast re-scheduled at the next app launch, since the Windows plugin has no
repeating API); its preference syncs through the backend so the same time
applies on the web and across devices. Tapping the notification opens the
dashboard.

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

Android has compile-time-separated `play` and `research` flavors. Both declare
an Accessibility Service that supports:

- Chrome (`com.android.chrome`) and Edge
  (`com.microsoft.emmx`) URL/title/headings/anchor extraction; the Research
  flavor additionally observes Opera (`com.opera.browser`), Opera Mini
  (`com.opera.mini.native`), UC Browser (`com.uc.browser`), and Firefox
  (`org.mozilla.firefox`);
- bounded, debounced, single-threaded local classification;
- local Back navigation plus an accessibility overlay Pattern Interrupt;
- versioned prominent disclosure before the user is sent to Accessibility
  Settings;
- signed, device-bound ES256 grants verified against pinned backend public
  keys and encrypted with Android Keystore after verification;
- daily allowlisted aggregate counters and last-known-good artifact loading;
- optional low-priority protection-health notification.

The Play flavor observes Chrome and Edge only; Settings/package-installer
monitoring is absent from its source set and accessibility configuration. The
Research flavor additionally observes Opera, Opera Mini, UC Browser, and
Firefox (best-effort via the editable-URL fallback; per-browser URL-bar
resource IDs are not hardcoded), and contains transparent settings/uninstall
friction tied to bounded approval or emergency grants. Other browsers and
arbitrary Android WebViews are not claimed as covered. A sideloaded app cannot make
itself impossible to uninstall; the research prototype adds OS-supported
friction and transparent recovery rather than unsafe device-owner behavior.

Release signing is intentionally separate. Play uses
`PLAY_KEYSTORE_PATH`, `PLAY_KEYSTORE_PASSWORD`, `PLAY_KEY_ALIAS`, and
`PLAY_KEY_PASSWORD`; Research uses the matching `RESEARCH_` variables. Grant
verification uses the public `PROTECTION_GRANT_TRUST_STORE_BASE64` build value:
base64 of a JSON map from `kid` to base64 DER SubjectPublicKeyInfo for each
current/next P-256 key. Empty or malformed trust configuration rejects grants.
The standard flavor outputs are `app-play-release.aab` and
`app-research-release.apk`; no release build or signing evidence is claimed
until those artifacts are independently verified.

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
command. The supported pilot installer is the per-machine MSI under
`windows/installer/`: it places immutable binaries under `Program Files`,
registers the LocalSystem service with SCM recovery, and exposes a normal
elevated Windows Installer removal path. In-app maintenance remains gated by a
signed device-bound removal/emergency grant. The PowerShell files under
`windows/scripts/` are developer/evidence helpers and are not shipped by the
MSI. Windows runtime, signing, and uninstall behavior still require validation
on a Windows VM/device.

The Windows service is split by responsibility under `windows/service/`:
runtime/SCM lifecycle, WebSocket handling, named-pipe commands, local state,
local artifact loading and integrity checks, opt-in evidence capture, user-agent launch, and small
platform support modules. The
Flutter runner similarly uses `native_protection_*.{cpp,h}` modules for codec,
channels, pipe transport, events, and settings monitoring. This keeps IPC,
credential storage, and local artifact integrity logic independently reviewable. Pipe operations
are cancellable during shutdown, and the Windows service joins its socket
workers before Winsock teardown.

## Phase 4 evidence capture

Latency evidence is disabled by default and remains device-local. When an
approved evaluator enables it, Android and Windows write bounded JSON Lines
containing opaque run/device/scenario labels, artifact versions, and durations
only. They never record URL, domain, DOM, title, decision score, account ID, or
browsing timestamp. `input_to_visible_ms` measures complete supported local
input through the first committed Pattern Interrupt frame.

Android evidence mode and export:

```sh
./scripts/phase4-android-evidence.sh enable --device SERIAL \
  --run-id RUN_ID --device-alias DEVICE_ALIAS --scenario SCENARIO
./scripts/phase4-android-evidence.sh export --device SERIAL \
  --output android-latency.jsonl
./scripts/phase4-android-evidence.sh disable --device SERIAL
```

Windows evidence mode/export and the ordinary process-kill recovery scenario
run from an elevated PowerShell on an approved disposable VM:

```powershell
.\windows\scripts\phase4-evidence.ps1 Enable `
  -RunId RUN_ID -DeviceAlias DEVICE_ALIAS -Scenario SCENARIO
.\windows\scripts\phase4-evidence.ps1 Export -Output windows-latency.jsonl
.\windows\scripts\phase4-evidence.ps1 Disable
.\windows\scripts\run-phase4-hardening.ps1 `
  -RunId RUN_ID -DeviceAlias DEVICE_ALIAS `
  -Output windows-resilience.json -AcknowledgeDisposableVm
```

Android resilience capture likewise requires an explicitly acknowledged
disposable device:

```sh
./scripts/run-phase4-android-hardening.sh --device SERIAL \
  --run-id RUN_ID --device-alias DEVICE_ALIAS \
  --output android-resilience.json --acknowledge-disposable-device
```

These harnesses emit the standardized `phase4_resilience_run` shape for one
ordinary process-kill cell. Remaining approved matrix scenarios must be
captured with the workbench template and reviewed; an unexecuted scenario is
never a passed evaluation.

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
email request and a single-use 12-character code.
The client remains `user`-only. If an admin-provisioned student signs in with a
temporary password, the login screen completes the required first-password
change before accepting the normal access/refresh session.

## Validate

```sh
./scripts/verify.sh
./scripts/verify-ai-context.sh
```

`verify.sh` runs the l10n module merge check (`scripts/merge_l10n.py --check`)
and then `flutter analyze`. Unit tests and platform builds are explicit
checks. The portable Windows Hybrid-v2 fixture can also be compiled directly
from `windows/protection/hybrid_classifier_test.cpp`.

CI uploads only clearly labelled, short-retention debug artifacts; it does not
create a public `latest` release. Tag-triggered signed candidates are gated by
protected environments and are retained as workflow artifacts only. The
artifact matrix, signing inputs, Play submission checklist, Research APK
pilot, and Windows MSI pilot are documented in
[`docs/release/README.md`](docs/release/README.md). No debug or unsigned file
is a user-facing release.
