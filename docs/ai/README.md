# Flutter Client AI Context

Context version: `2026-07-15.2`

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
| Auth/onboarding/dashboard/recovery UI and data layers | Implemented prototype | repository and widget tests cover selected paths |
| Model integration contract | Stub, not wired | `AIInferenceStub` has no loading/classification call path |
| Pattern Interrupt screen | Implemented UI | native detection-to-screen trigger still needs end-to-end proof |
| Android protection bridge | Prototype | platform calls are best-effort and require device validation |
| Windows service/WebSocket | Stub, not built | service source is absent from runner CMake target |
| Offline queue/reminder/asset helpers | Prototype | background reliability is not fully platform-scheduled |

Target architecture in comments or proposal documents does not change these
states. Update the table only with code, wiring, and verification evidence.

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
context-version bump.
