# Flutter Client AI Context

Context version: `2026-07-19.1`

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
| Auth/device/setup/settings | Implemented code-complete prototype | session refresh is single-flight; device registration is stable-instance upsert; auth fields validate inline; password changes keep the dialog and values open for contextual server errors; localized safe messages and dismissible feedback are shared across features; profile, locale, haptics, notifications, setup, and artifact health are wired |
| Protection/analytics/accountability UI | Implemented code-complete prototype | native health is authoritative; analytics are 7/30-day aggregate-only; registration declares the student role, group-code preview/confirm consumes the active membership contract, pause/uninstall requests use `membership_id`, and approved grants remain device-bound |
| Hybrid-v1 local classifier | Implemented dummy prototype | Android and portable Windows core load versioned rules + synthetic LR weights and pass committed fixtures; artifact is explicitly untrained/unevaluated |
| Pattern Interrupt and recovery handoff | Implemented code path | seven-second native/Flutter paths, reduced motion, offline grounding/help, and browsing-data-free web handoff are wired; device evidence remains required |
| Android protection runtime | Implemented code-complete prototype | active manifest service, Chrome/Edge extraction, local decision, Back/overlay, settings friction, Keystore grant, aggregate sync, and artifact checks; analyzer passes, Android compile/device proof remains |
| Windows service + user-session agent | Implemented code-complete prototype | separate CMake service target, authenticated loopback WebSocket, DPAPI state, logon-SID pipe, Flutter bridge, SendInput action, SCM recovery, scripts, and portable classifier fixture; Windows compile/VM proof remains |
| Release scaffolding | Implemented | tag CI requires Android release signing and Windows Authenticode inputs; no debug-signing fallback |

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
