# Android Research anti-uninstall testing

The Flutter repository owns the Android Research implementation and
`TamperActionDetector` unit tests. Cross-device execution, evidence schema,
Firebase Device Streaming guidance, promotion, and the canonical result belong
to the public testing repository:

- Runbook: <https://github.com/Gamblock-AI/Gamblock-AI-Testing/blob/main/docs/ai/android-anti-uninstall-testing.md>
- Canonical Flutter/Android report: <https://github.com/Gamblock-AI/Gamblock-AI-Testing/blob/main/flutter/report.md>

Do not add a second summary or commit screenshots, ADB traces, serial numbers,
URLs, DOM text, or participant data here. Product behavior changes belong in
this repository; test evidence changes belong in `Gamblock-AI-Testing`.

## Platform limitation

Research removal resistance is best-effort for a standard Android APK. The
active Device Administrator blocks uninstall while Android considers it active,
but an OEM Settings flow can require the user to deactivate the administrator
and then hand the action to the package installer. The device-admin callback
can warn and persist the tamper state, but it cannot veto that OS decision.
Accessibility detection and Back/Home navigation improve friction and
auditability, yet cannot override Settings/package-installer authority or
guarantee survival when an OEM stops the protection process. Guaranteed
prevention through Device Owner/MDM/kiosk provisioning is outside this APK's
current scope.
