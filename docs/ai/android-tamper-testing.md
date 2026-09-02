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
