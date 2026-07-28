# Flutter Client AI Context

Context version: `2026-07-29.1`

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
| Auth/device/setup/settings | Implemented code-complete prototype with external configuration gates | persisted three-step onboarding routes guest students to login/register and authenticated students to `/dashboard`; password visibility/autofill, native 12-character email-code reset, email-verification refresh/resend, role rejection before token persistence, capability-aware Settings, and Google login/link code paths are wired. Android has the official provider plugin and still needs real OAuth client/signing configuration; Windows uses loopback state/nonce/PKCE and needs VM evidence. |
| Dashboard/analytics/accountability UI | Implemented code-complete prototype | bottom navigation adapts to a Windows/tablet rail; the dashboard uses truthful local health and setup state; analytics are 7/30-day aggregate-only; students control four aggregate-sharing categories, normal/unsafe exit and cancellation, approval cancellation/application, group preview/confirm, and device-bound grants. No browsing or journal detail is added. |
| Daily missions + EXP/level | Implemented (display + server-verified claim; adjust/replace deliberately web-only) | the dashboard shows the account's server-rotated primary/bonus missions with truthful locked/claimable/claimed/skipped states, claims EXP via `/v1/missions/claim` with haptic/snackbar feedback, and renders the shared journey level titles (`levelTitle1..7`, identical to the website). Locked web-side missions link out with locale+path only. Non-student sessions and 403 responses hide the section silently. |
| Gami mascot presence + analytics appreciation | Implemented supporting UI | shared `GamiCard` plus real generated mascot poses (`gami-{wave,meditate,celebrate,point}.webp`, bundled locally), dashboard hero mascot behind content, all-missions-done encouragement with a gated entrance, analytics appreciation card framing blocks/interventions as helpful pauses over the period (aggregate counts only, no fear/shame framing), and Gami in the empty trend overlay. The dashboard is a slim single-header surface (hero-only, in-hero refresh), tabs share `AppBarTitle` and `AppSpacing.screenPadding`, and dashboard/intro blocks enter with a gentle gated stagger. An engagement pass added: a contextual hero Gami (all-missions-done / recent-pause / first-open states, deterministic), a weekly appreciation card on the dashboard reusing 7-day aggregates, local `PauseMoment` bookkeeping (secure storage, 30-entry/30-day cap) with a gentle next-visit acknowledgment card — a completed in-app grounding also syncs best-effort as a regular `grounding_54321` recovery practice (kind+duration only) so it feeds badges, rhythm, and the sixth mission; full 13-badge journey parity plus a non-punitive presence-rhythm line on the analytics screen (`lib/features/journey/`), a standalone login-gated `/breathing` exercise reusing the PI orb (box and 4-7-8 patterns; PI itself untouched), total EXP in the level chip, and an opt-in Android daily check-in reminder (`flutter_local_notifications` + timezone, inexact daily schedule, neutral lock-screen copy, hidden on Windows). |
| Hybrid-v2 local classifier | Implemented trained-artifact prototype; not evaluated | supplied ONNX graph is reproducibly exported without unpickling into 5,664 unigram + 4,336 bigram weights, 14 scaled URL features, LR bias/weights, `0.75/0.25` fusion, and threshold `0.4`; Android and Windows native authorities load the same hashed artifact/rules/fixtures. Supplied metrics remain unverified because dataset card, split/training source, FPR slices, and preprocessing-parity evidence are absent |
| Pattern Interrupt and recovery handoff | Implemented code path | seven-second native/Flutter paths, reduced motion, offline grounding/help, and browsing-data-free web handoff are wired; device evidence remains required. The Flutter screen adds a breath-phase cue synced to the orb, a thin digit-free progress ring for the sanctioned pause, a stable countdown pill, height-reserved action slots, haptics, and an interactive 5-4-3-2-1 grounding stepper with per-sense steps and a calm completion state. The Android native overlay (`PatternInterruptOverlay.kt`) is a separate surface and was intentionally not changed. The recovery handoff screen is rebranded (mesh background, SurfaceCard, mascot, eyebrow, single title, gated entrance animation). |
| Android protection runtime | Implemented code-complete prototype | active manifest service, Chrome/Edge extraction, local decision, Back/overlay, settings friction, Keystore grant, aggregate sync, and artifact checks; analyzer passes, Android compile/device proof remains |
| Windows service + user-session agent | Implemented code-complete prototype | separate CMake service target, authenticated loopback WebSocket, DPAPI state, logon-SID pipe, Flutter bridge, SendInput action, SCM recovery, scripts, portable classifier fixture, and a non-signing Windows debug compile CI job are wired; a successful runner result and VM proof remain external evidence gates |
| Release scaffolding | Implemented operational workflow | every successful `main` commit force-updates the mutable `latest` tag/release with development debug assets and explicitly named `production-debug` assets using the production API/site URLs; signed production jobs remain behind `ENABLE_PRODUCTION_RELEASE=true` with Android keystore and Windows Authenticode inputs; debug/unsigned artifacts are never presented as signed |

Target architecture in comments or proposal documents does not change these
states. Update the table only with code, wiring, and verification evidence.

Windows service implementation is organized by responsibility in
`windows/service/`: runtime lifecycle, WebSocket transport/handler, named-pipe
handler, artifact updater, local state, user-agent launcher, and small support
modules. The Flutter runner mirrors that split in `native_protection_*.{cpp,h}`
for codec, channels, pipe transport, events, and settings monitoring. The
split does not change the loopback or Flutter pipe contracts. Pipe operations
are cancellable during shutdown, and the service joins WebSocket workers before
tearing down Winsock.

Proposal traceability: this client owns `PKM-PLAT-001`, `PKM-PLAT-002`,
`PKM-PLAT-003`, `PKM-AI-001`, `PKM-AI-002`, `PKM-AI-003`, `PKM-AI-004`,
`PKM-AI-005`, `PKM-AI-006`, `PKM-AI-007`, `PKM-BLOCK-001`, `PKM-BLOCK-002`,
`PKM-INT-001`, `PKM-INT-002`, `PKM-INT-003`, `PKM-INT-004`, `PKM-ACC-002`,
`PKM-ACC-003`, and `PKM-ACC-004` runtime outcomes. The required pipeline
includes URL rules, DOM title/headings/anchors, BoW, Logistic Regression, local
decision/block, a 5–10 second Pattern Interrupt, and a browsing-data-free
recovery handoff.

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
