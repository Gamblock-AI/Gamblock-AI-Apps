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
| Auth/device/setup/settings | Implemented code-complete prototype with external configuration gates | persisted three-step onboarding routes guest students to login/register and authenticated students to `/dashboard`; password visibility/autofill, native 12-character email-code reset, email-verification refresh/resend, role rejection before token persistence, and capability-aware Settings are wired. WhatsApp OTP (Fonnte) is the account gate: after register or sign-in on an unverified account the client carries the short-lived `verification_token` (plus an `origin` of `register`/`login`) into `/verify-phone`; a successful verify issues a fresh session, so a login-origin flow completes the session and routes to `/dashboard` directly while a register-origin flow still routes to `/login`. Tapping the Settings avatar opens a gallery/camera/update/delete flow; images are cropped, zoomed, 90°-rotated, and encoded to a square WebP before the existing `/v1/me/avatar` upload/delete call. The avatar route is auth-protected so images load through the authenticated Dio client. |
| Daily check-in reminder | Implemented supporting feature (Android + Windows) | opt-in daily reminder scheduled locally via `flutter_local_notifications`: Android uses a repeating inexact daily schedule, Windows a one-shot toast re-scheduled on the next app launch (plugin has no repeating API); preference syncs through the backend (`/v1/me/reminder-preference`) and notification taps open `/dashboard`; neutral rotating copy; Windows native toast-activator delivery still needs runtime evidence |
| Dashboard/analytics/accountability UI | Implemented code-complete prototype | bottom navigation adapts to a Windows/tablet rail; the dashboard uses truthful local health and setup state; analytics are 7/30-day aggregate-only. Mobile accountability uses a compact partner hero, grouped consent/exit actions, and status timeline; the actual partner avatar is loaded through authenticated Dio from the optional workspace `owner_avatar_url`, with monogram fallback. Students control four aggregate-sharing categories, normal/unsafe exit and cancellation, approval cancellation/application, group preview/confirm, and device-bound grants. No browsing or journal detail is added. |
| Visual system alignment (web parity) | Implemented code-complete | tokens in `lib/core/theme/` match the website palette (navy/crimson/sky/azure/sage/amber), radius and card/button shapes unified (cards 16, inputs 12, buttons pill), interactive accents moved from the wireframe blue/violet to the web sky/navy; all non-immersive Flutter surfaces share a palette-derived blue mesh with standard/strong intensity while intro and Pattern Interrupt keep their purpose-built full-bleed treatments. Login, registration, password recovery, and WhatsApp verification retain the prominent stacked Gamblock-AI lockup. Empty/access/error cards, skeletons, busy controls, inline auth errors, sync notices, setup steps, self-test results, and snackbars use a shared branded state language with reduced-motion handling and Gami image fallbacks; the mobile glass bottom nav's centre button now opens Mini Games directly while the rail keeps only primary destinations; `AppColors.blueAccent`/`violetAccent` are legacy aliases that now resolve to sky/azure. |
| First-time dashboard tour | Implemented supporting UI | A six-step spotlight coach-mark tour mirrors the website's dashboard tour: welcome header, protection hero, sensor grid, centre mini-games FAB, bottom navigation, and profile avatar. It runs once per account after the first login lands on `/dashboard` (seen flag persisted in secure storage as `dashboard_tour_seen_v1`), is skippable, honors reduced motion, resolves copy through a dedicated `tour` l10n module, and auto-skips targets absent from a layout (e.g. the FAB on a wide rail). All targets are visible on `/dashboard` plus the shell, so no cross-screen navigation is involved. |
| Mobile mini games | Implemented supporting UI | The mobile centre navigation button opens four native, website-parity games: Spectrum Sprint, Picture Forge, Twin Trace, and Brain Summit. Their hub thumbnails use one generated 3D pastel art direction; the study-corner and blueberry assets retain their puzzle/card roles. Picture Forge uses a pre-play image/difficulty selector, persistent in-play reference image, moves/time/piece status, reset, reshuffle, and challenge change; Twin Trace uses a pre-play board-size selector, three-second preview, moves/time/pair status, reset, and difficulty change. Each session is in memory only: no score, answers, card order, puzzle state, timing, analytics, EXP, or partner/LLM/SPK data is persisted or synced. Leaving an active game through its header, system back, bottom navigation, or centre button requires confirmation, then discards the session so reopening begins from the start; configuration and result screens may be left directly. The former mobile quick-actions sheet and standalone recovery handoff route were removed; the native Pattern Interrupt path remains independently available for protection events. |
| Protection dashboard + Gami | Implemented supporting UI | The dashboard adapts the NeedMCP `wellness-home-focus` composition into the existing product system: the avatar/greeting/status topbar is retained, the truthful local status is presented in a navy Gami hero, setup/self-test use compact responsive focus cards, and sensor state flows through compact two-column phone/four-column wide grids. The hero now uses responsive full-bleed portrait/landscape scenes whose Gami identity is anchored to `gami.webp`; first-open still changes the greeting copy without adding a duplicate mascot. Each truthful local signal (service, browser relay, permission, and model/rules) has a dedicated generated transparent Gami pose, while device-registration states use a separate generated Gami-with-device cutout. Existing palette tokens, callbacks, pull-to-refresh, text scaling, reduced-motion behavior, aggregate appreciation, accountability states, and app-shell navigation remain; no synthetic progress or notification state was introduced. Native missions, EXP/level, journey badges, standalone breathing, pause acknowledgement, and recovery-practice bookkeeping were removed so the client stays a thin protection surface. The generated full-bleed dashboard backgrounds, sensor/device-registration assets, and six intro scenes are app-only artwork; `gami.webp` remains the shared identity anchor and load-error fallback. |
| Hybrid-v2 local classifier | Implemented trained-artifact prototype; not evaluated | supplied ONNX graph is reproducibly exported without unpickling into 5,664 unigram + 4,336 bigram weights, 14 scaled URL features, LR bias/weights, `0.75/0.25` fusion, and threshold `0.4`; Android and Windows native authorities load the same hashed artifact/rules/fixtures. Supplied metrics remain unverified because dataset card, split/training source, FPR slices, and preprocessing-parity evidence are absent |
| Pattern Interrupt | Implemented code path; runtime evidence pending | Seven-second reduced-motion/offline UI, opaque per-intervention IDs, visible-frame acknowledgement, completion, duplicate coalescing, and browsing-data-free recovery handoff are wired. Android is Flutter-first with a bounded native-overlay fallback; Windows retains and replays an unacknowledged ID after user-agent reconnect, rejects native close requests during the mandatory seven-second pause, and completes the ID when the user closes afterward. Android device and Windows VM traces remain required. |
| Android protection runtime | Implemented code-complete prototype; flavor build/device evidence pending | Compile-time `play`/`research` source sets share Chrome/Edge extraction, local decision, Back handling, Flutter-first intervention delivery with native-overlay fallback, versioned prominent disclosure, aggregate sync, and local artifact integrity checks. Only Research compiles action-aware Settings/package-installer/launcher friction and the audited Samsung Internet, Brave, Opera, Firefox, Xiaomi/Vivo/Oppo, DuckDuckGo, and UC Browser package families through the `additionalBrowserPackages` hook; known controls are used where available and the remainder use a best-effort editable-URL fallback. Removal friction covers launcher uninstall dialogs (OEM launchers such as MIUI never emit `TYPE_VIEW_LONG_CLICKED`, so the dialog content itself is treated as evidence) and distinguishes strong uninstall tokens ("uninstal", "copot", "hapus aplikasi") from weak/ambiguous ones so MIUI's "Uninstal akan menghapus semua data" classifies as uninstall, not clear-data. Research additionally ships a `ProtectionDeviceAdminReceiver` (no password policy) activated from the dashboard: while the device administrator is active Android itself refuses uninstall, and the partner-approved `uninstall_detected` grant deactivates the admin (`DevicePolicyManager.removeActiveAdmin`) before `ACTION_DELETE`. Play restricts native dispatch and Accessibility XML to Chrome/Edge. Passive App Info is not treated as tamper evidence; uninstall, Accessibility-disable, force-stop, and clear-data actions are distinguished, and only a valid `uninstall_detected` grant can begin normal Android removal after user confirmation. For a student with no active accountability partner, the protection dashboard surfaces a "Remove app" path (10-second countdown plus typed confirmation) that requests a short-lived, single-use standalone `uninstall_detected` grant from `POST /v1/devices/standalone-removal-grant` before calling `beginApprovedRemoval`, so the device admin is deactivated and the uninstall proceeds without a partner; a live membership keeps the student on the partner-approval flow. Native grants require a compact ES256 token, pinned `kid`, strict claims/TTL, immutable device ID, and a matching RFC 7638 thumbprint for a non-exportable Android Keystore P-256 key; an empty trust store fails closed. Daily aggregates carry a privacy-preserving 24-slot hourly histogram, while optional blocked-event timestamp population remains a follow-up. Sensing is navigation-committed only: `TYPE_WINDOW_CONTENT_CHANGED` events are processed only when they carry subtree/pane change types, so keystrokes and URL-bar text edits are never extracted or classified; scans fire on window changes, link clicks, and page-level content changes. Model loading runs off the main thread (activity + service) and grant-state verification is TTL-cached (3 s) to keep the Accessibility main thread light. The accessibility service and its `specialUse` foreground keep-alive run in a dedicated `:protection` process so OEM task-killers (MIUI/HyperOS swipe-away, which kills FGS processes on the UI task's process) cannot stop on-device blocking; the Flutter UI process talks to it through an app-internal `ContentProvider` bridge (`ProtectionBridgeProvider`) plus an in-app event broadcast, and the provider tracks the UI's binder death so Flutter-first presentation is released to the native overlay when the UI task dies. The keep-alive enters the foreground state unconditionally before any early exit so a `startForegroundService` call can never trigger `ForegroundServiceDidNotStartInTimeException` (which previously crash-looped the accessibility service into a "Tidak berfungsi" state on devices without the notification permission). A battery-optimization exemption is requested after setup; manual force-stop still unbinds the service until the app is reopened (OS-level, not resistible), and the `permission_revoked` aggregate now increments only on a true disable. The snapshot reports `service_running` from the actual binding in the protection process, not the Settings toggle, so an enabled-but-unbound service (Settings shows "Tidak berfungsi") surfaces as `status=inactive`/`degraded_reason_code=service_not_running` with permission still `granted`; the dashboard listens for the service's `protection_status` event so the state self-corrects once the system rebinds (opening the app triggers the rebind; a toggle off/on in Accessibility settings is the repair path when rebind fails). The native overlay's video-background MediaPlayer callbacks are all crash-guarded so surface destruction after dismissal can no longer throw `IllegalStateException` and kill the protection process (the previous one-block-then-dead failure on real devices). Debug (`--debug`) builds on low-end devices can appear frozen on the dashboard because Flutter's debug-only `!semantics.parentDataDirty` assertion (go_router's `ModalBarrier` leaves blocked nodes dirty) storms every frame; release builds compile the assert out and are unaffected — use release/profile builds for on-device QA. Android flavor compilation, real-device runs, Play review, and reviewed scenario evidence remain external gates. |
| Windows service + user-session agent | Implemented code-complete prototype; runtime evidence pending | Separate CMake service target, authenticated loopback WebSocket, DPAPI state, logon-SID pipe, Flutter bridge, checked browser-scoped `SendInput` Back with close-tab fallback, SCM recovery, and portable classifier fixture are wired. LocalSystem retains a pending intervention until the active-session agent acknowledges visible/completed state and replays the same ID after reconnect. A valid uninstall grant is consumed before LocalSystem starts MSI removal from the registered ProductCode; direct elevated MSI removal remains the administrator break-glass path. The aggregate store keeps the same optional hourly histogram so Windows reports consistent "jam rawan" data. A successful runner build and reviewed VM/device matrix remain external evidence gates. |
| Evaluation | Instrumented; not evaluated | Hybrid/model/rule metrics, FPR slices, native latency, retention, and evidence completeness. No approved dataset, real-device matrix, or reviewer sign-off is present. |
| Release scaffolding | Implemented operational workflow; external signing/build evidence pending | Diagnostic PR/main jobs build both Android flavors, a Windows ZIP, and an unsigned MSI packaging check without production secrets. Production and Staging release candidates are consolidated into one unified release per version via the standard AI release SOP (`docs/ai/release-workflow.md`). A semantic-version tag (or the same semver via `workflow_dispatch`) produces protected workflow artifacts: a separately signed Play AAB, Research APK, and Windows pilot MSI. `staging-release.yml` requires the public `PROTECTION_GRANT_TRUST_STORE_BASE64`, validates it as a non-empty JSON key map in both jobs, and embeds it in the Research APK and self-signed Windows MSI builds before attaching them to the versioned GitHub Release. CI success is not device/VM evidence. All private signing material remains in protected GitHub environments, the local owner backup, and the owner's password manager—see `docs/release/README.md`. The complete matrix is in `docs/ai/distribution-matrix.md`. |

Target architecture in comments or proposal documents does not change these
states. Update the table only with code, wiring, and verification evidence.

Windows service implementation is organized by responsibility in
`windows/service/`: runtime lifecycle, WebSocket transport/handler, named-pipe
handler, local artifact loader, local evidence recorder, local state, user-agent launcher, and small support
modules. The Flutter runner mirrors that split in `native_protection_*.{cpp,h}`
for codec, channels, pipe transport, intervention events, and browser actions. The local
pipe contract carries the block-action result plus the opaque intervention ID,
visible acknowledgement, and completion; it never carries URL, DOM, domain, or
score. Pipe operations are cancellable during shutdown, and the service joins
WebSocket workers before tearing down Winsock.

The required pipeline includes URL rules, DOM title/headings/anchors, BoW,
Logistic Regression, local decision/block, a 5–10 second Pattern Interrupt,
and a browsing-data-free recovery handoff.

## Default AI validation

The Flutter client accepts only the `user` account role. Admin-provisioned
student accounts can complete the backend's purpose-specific, ten-minute
first-login password-change exchange before the normal session is stored. The
client also identifies itself to the backend with the `X-Client-Type: native`
header on every request, so the session-issuing auth endpoints reject
non-student accounts server-side with the `student_only` (403) code; the
client-side role checks remain as defense in depth.

Web (`web/`) is a developer-convenience target only, used when no Android/
Windows hardware is available: run `flutter run -d chrome --web-port 45051`
with `API_BASE_URL` pointing at the local backend. It is not a shipped
platform; native-only surfaces (device registration, Windows section,
check-in reminders) degrade gracefully behind `PlatformInfo` and `kIsWeb`.

Run `./scripts/verify.sh` (l10n module merge check via
`scripts/merge_l10n.py --check`, then `flutter analyze`). When context changed,
also run `./scripts/verify-ai-context.sh`. Dependency installation, tests,
Android/Windows builds, packaging, and full verification run only when
explicitly requested by the user. GitHub Actions uses the diagnostic and
signed lanes
documented in `docs/ai/distribution-matrix.md`.

Localization sources live per-module under `lib/l10n/modules/<locale>/*.json`
(mirroring the website's next-intl modules) and are merged into the single
`app_<locale>.arb` files that `flutter gen-l10n` consumes via
`scripts/merge_l10n.py`. `scripts/merge_l10n.py --check` enforces en/id key
parity, duplicate detection, and metadata integrity; keep module files for both
locales in sync when adding keys.

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
