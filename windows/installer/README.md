# Windows MSI packaging

`GamblockAI.wixproj` is the production per-machine installer entrypoint. It
packages an already staged Flutter Windows x64 release bundle, installs binaries
under `Program Files`, creates a locked `ProgramData\GamblockAI` state directory,
and registers `GamblockAIProtection` declaratively as an automatic LocalSystem
service with SCM restart recovery.

The MSI is intentionally unsigned. Sign the application binaries first, build
the MSI, then sign the MSI in the release system; no certificate or private-key
configuration belongs in this project.

## Inputs and output

From the Flutter repository root on Windows:

```powershell
dotnet build windows\installer\GamblockAI.wixproj `
  -c Release `
  -p:Platform=x64 `
  -p:BundlePath="C:\absolute\path\to\build\windows\x64\runner\Release" `
  -p:ProductVersion=1.0.0
```

The predictable output is:

```text
windows\installer\bin\x64\Release\GamblockAI-1.0.0-x64.msi
```

`BundlePath` must contain `gamblock_ai_apps.exe` and
`gamblock_ai_service.exe`. Debug symbols, import libraries, and legacy scripts
are excluded from the MSI.

## Protection-grant trust store

The service embeds public verification keys when the native bundle is built,
not when the MSI is built. Set the public environment variable
`PROTECTION_GRANT_TRUST_STORE_BASE64` before configuring/building Flutter. Its
decoded value must be a JSON object mapping each accepted `kid` (current and
next rotation key) to a standard-base64 DER SubjectPublicKeyInfo for an ECDSA
P-256 public key:

```json
{"current-2026":"<base64 DER SPKI>","next-2027":"<base64 DER SPKI>"}
```

Base64-encode that complete JSON object and supply the resulting single-line
value. An empty or malformed store makes all grants fail closed. The trust store
is public material; never put a private signing key in this variable. A CMake
caller may alternatively pass the same value as
`-DPROTECTION_GRANT_TRUST_STORE_BASE64=...`.

Standard in-app removal uses a signed, device-bound `uninstall_detected` or
`emergency_access` grant. The LocalSystem service consumes that grant, reads the
installed ProductCode from its protected HKLM registration, and starts a normal
silent Windows Installer removal. A `pause_protection` grant cannot remove the
product. Direct elevated MSI removal remains the explicit administrator
break-glass path: Windows Installer can stop and remove the service through SCM
without hidden navigation or keystroke interception.

The scripts under `windows/scripts/` are developer/evidence helpers and are not
packaged. In particular, `uninstall-service.ps1` invokes the explicit
administrator service-removal command; it is not the participant-facing
grant-approved MSI path.
