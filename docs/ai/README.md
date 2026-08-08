# Flutter Client AI Context


Jika ada pertentangan dengan `pkm_proposal.md`, proposal PKM adalah sumber mutlak.

## Product capsule

Gamblock-AI protects Indonesian university students from online gambling while
supporting recovery and social accountability. The Flutter client is the
intended Android/Windows blocking authority. Browsing content must remain on
the device; the backend receives aggregate events only.

## Hard boundaries

- No raw DOM, URL, domain, screenshot, or browsing history leaves the device.
- The extension never classifies or blocks.
- Never use Windows critical-process APIs.
- Preserve local/offline protection and encrypted recovery-data contracts.
- Error codes mirror the backend and website catalogs.

## Current capability truth

| Area | State | Evidence/limit |
|---|---|---|
| Auth/device/setup/settings | Implemented code-complete prototype with external configuration gates | persisted three-step onboarding routes guest students to login/register and authenticated students to `/dashboard`; password visibility/autofill, native 12-character email-code reset, email-verification refresh/resend, role rejection before token persistence, and capability-aware Settings are wired. |
| Daily check-in reminder | Implemented supporting feature (Android + Windows) | opt-in daily reminder scheduled locally via `flutter_local_notifications`: Android uses a repeating inexact daily schedule, Windows a one-shot toast re-scheduled on the next app launch (plugin has no repeating API); preference syncs through the backend (`/v1/me/reminder-preference`) and notification taps open `/dashboard`; neutral rotating copy; Windows native toast-activator delivery still needs runtime evidence |
| Dashboard/analytics/accountability UI | Implemented code-complete prototype | bottom navigation adapts to a Windows/tablet rail; the dashboard uses truthful local health and setup state; analytics are 7/30-day aggregate-only; students control four aggregate-sharing categories, normal/unsafe exit and cancellation, approval cancellation/application, group preview/confirm, and device-bound grants. No browsing or journal detail is added. |
| Website recovery handoff | Implemented code-complete prototype | The client opens the privacy-safe web handoff with locale plus fixed source category only. Detailed intention, check-in, mission, education, skill, journal, and weekly-review surfaces remain website-owned. |
| Protection dashboard + Gami | Implemented supporting UI | Dashboard hero, setup/self-test, aggregate appreciation, and first-open mascot state remain. Native missions, EXP/level, journey badges, standalone breathing, pause acknowledgement, and recovery-practice bookkeeping were removed so the client stays a thin protection surface. |
| Hybrid-v2 local classifier | Implemented trained-artifact prototype; not evaluated | supplied ONNX graph is reproducibly exported without unpickling into 5,664 unigram + 4,336 bigram weights, 14 scaled URL features, LR bias/weights, `0.75/0.25` fusion, and threshold `0.4`; Android and Windows native authorities load the same hashed artifact/rules/fixtures. Supplied metrics remain unverified because dataset card, split/training source, FPR slices, and preprocessing-parity evidence are absent |
| Pattern Interrupt and recovery handoff | Implemented code path | Seven-second native/Flutter paths, reduced motion, offline grounding/help, and browsing-data-free web handoff are wired; device evidence remains required. |
| Android protection runtime | Implemented code-complete prototype | active manifest service, Chrome/Edge extraction, local decision, Back/overlay, settings friction, Keystore grant, aggregate sync, and artifact checks are wired. Android compile/device runs and reviewed scenario evidence remain external gates. |
| Windows service + user-session agent | Implemented code-complete prototype | separate CMake service target, authenticated loopback WebSocket, DPAPI state, logon-SID pipe, Flutter bridge, SendInput action, SCM recovery, and portable classifier fixture are wired. A successful runner build and reviewed VM/device matrix remain external evidence gates. |
| Evaluation | Instrumented; not evaluated | Hybrid/model/rule metrics, FPR slices, native latency, retention, and evidence completeness. No approved dataset, real-device matrix, or reviewer sign-off is present. |
| Release scaffolding | Implemented operational workflow | every successful `main` commit force-updates the mutable `latest` tag/release with development debug assets and explicitly named `production-debug` assets using the production API/site URLs; signed production jobs remain behind `ENABLE_PRODUCTION_RELEASE=true` with Android keystore and Windows Authenticode inputs; debug/unsigned artifacts are never presented as signed |

Target architecture in comments or proposal documents does not change these
states. Update the table only with code, wiring, and verification evidence.

Windows service implementation is organized by responsibility in
`windows/service/`: runtime lifecycle, WebSocket transport/handler, named-pipe
handler, artifact updater, local evidence recorder, local state, user-agent launcher, and small support
modules. The Flutter runner mirrors that split in `native_protection_*.{cpp,h}`
for codec, channels, pipe transport, events, and settings monitoring. The
split does not change the loopback or Flutter pipe contracts. Pipe operations
are cancellable during shutdown, and the service joins WebSocket workers before
tearing down Winsock.

The required pipeline includes URL rules, DOM title/headings/anchors, BoW,
Logistic Regression, local decision/block, a 5–10 second Pattern Interrupt,
and a browsing-data-free recovery handoff.

## Default AI validation

The Flutter client accepts only the `user` account role. Admin-provisioned
student accounts can complete the backend's purpose-specific, ten-minute
first-login password-change exchange before the normal session is stored.

Run `./scripts/verify.sh` (`flutter analyze` only). When context changed, also
run `./scripts/verify-ai-context.sh`. Dependency installation, tests, Android/
Windows builds, packaging, and full verification run only when explicitly
requested by the user.

## Related repositories and contracts

- Backend: `https://github.com/Gamblock-AI/Gamblock-AI-Backend`
- Website: `https://github.com/Gamblock-AI/Gamblock-AI-Website`
- Extension: `https://github.com/Gamblock-AI/Gamblock-AI-Browser-Extention`

WebSocket changes require mirrored extension work. Error-code changes require
backend and website catalog updates. Payloads must remain aggregate-only.

## Context maintenance

Update this file when wiring, native build inclusion, model status, commands,
or architecture changes. Shared invariant changes require an umbrella
context-version bump. Completion means code-complete prototype, not evaluated
model, real-device proof, signed release, or production readiness.
