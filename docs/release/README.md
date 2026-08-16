# Release and Pilot Runbook

Gamblock-AI has separate distribution identities because platform policy and
the PKM research prototype have different anti-removal boundaries. A successful
build is not evidence of store approval, Defender reputation, model quality, or
real-device correctness.

## Artifact matrix

| Artifact | Identity | Audience | Required protection behavior |
|---|---|---|---|
| Play AAB | `com.gamblock.gamblock_ai_apps` / Gamblock-AI | Public Android | Browser-only Accessibility, local classification/block/Pattern Interrupt; no Settings or uninstall interception |
| Research APK | `com.gamblock.gamblock_ai_apps.research` / Gamblock-AI Research | Approved PKM cohort | Full research prototype, including transparent best-effort settings/removal friction |
| Pilot MSI | Gamblock-AI Pilot | Approved Windows cohort | Per-machine LocalSystem service, partner-approved normal maintenance, administrator break-glass |
| Research staging APK + MSI | Research flavor + Gamblock-AI Pilot identity, staging backend | QA/test | Same protection behavior as the research/pilot variants but pointed at `api-staging.gamblock-ai.com`; published from the manual `staging-release.yml` lane |

Debug APKs, Windows ZIPs, and the diagnostic unsigned MSI are CI diagnostics
only. The Research staging release is a separate QA lane: its APK is debug
signed and its MSI uses the owner self-signed Authenticode PFX, so it must be
labelled staging-backed and not be presented as signed or production-ready.

## Signing boundaries

Keep four independent identities:

1. Google Play app-signing/upload key;
2. Android Research APK key;
3. Windows pilot Authenticode leaf certificate;
4. backend protection-grant ES256 key.

Never reuse one key for another purpose. Private material is never committed or
placed in `.env.example`. The backend receives a base64-encoded PKCS#8 P-256
private key through `PROTECTION_GRANT_SIGNING_PRIVATE_KEY` and its identifier
through `PROTECTION_GRANT_SIGNING_KEY_ID`.

Android and Windows receive only this public trust-store variable:

```text
PROTECTION_GRANT_TRUST_STORE_BASE64 = base64(
  JSON object mapping kid to base64 DER SubjectPublicKeyInfo P-256
)
```

The map contains the current and next public keys during rotation. Ship the new
public key before changing the backend signing `kid`; remove the old key only
after every supported client has moved beyond it. Empty, malformed, or unknown
trust data fails closed.

The tag-only signed release workflow expects protected environments and these
inputs:

- variables: `PROD_API_BASE_URL`, `WEB_BASE_URL`,
  `PROTECTION_GRANT_TRUST_STORE_BASE64`, `ENABLE_PRODUCTION_RELEASE`, and
  `ENABLE_WINDOWS_PILOT_RELEASE`;
- Play secrets: `ANDROID_PLAY_KEYSTORE_BASE64`, keystore password, and key
  password; `ANDROID_PLAY_KEY_ALIAS` is a non-secret environment variable;
- Research secrets: the corresponding keystore/password values;
  `ANDROID_RESEARCH_KEY_ALIAS` is a non-secret environment variable;
- Windows secrets: `WINDOWS_PILOT_SIGNING_PFX_BASE64` and password;
- optional public timestamp endpoint: `WINDOWS_TIMESTAMP_URL`.

Adding or rotating these values requires explicit owner authorization. The
diagnostic workflow never consumes these private inputs and creates only
short-retention Actions artifacts. The signed workflow creates retained,
versioned candidate artifacts; it does not publish to Google Play, create a
public Windows download, or mutate a `latest` tag.

## Local key preparation and GitHub CLI upload

Run the following on an owner-controlled machine. The generated directory and
password variables must stay outside Git and must never be pasted into chat.
Use separate Android keys; using the same key for Play and Research breaks the
distribution identity boundary.

### Windows PowerShell path

If you are using Windows, open **Windows Terminal → PowerShell** first. Do not
double-click a `.sh`, `.bat`, or `.ps1` file; a window launched that way can
close immediately after an error. Paste and run these commands one block at a
time:

```powershell
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\gamblock-secrets" | Out-Null
$KeyDir = "$env:USERPROFILE\gamblock-secrets"
$Keytool = (Get-Command keytool -ErrorAction Stop).Path

& $Keytool -genkeypair -v `
  -keystore "$KeyDir\gamblock-play-upload.jks" -storetype JKS `
  -alias gamblock-play-upload -keyalg RSA -keysize 2048 `
  -sigalg SHA256withRSA -validity 10000 `
  -dname "CN=Gamblock-AI Play Upload, O=Gamblock-AI, C=ID"

& $Keytool -genkeypair -v `
  -keystore "$KeyDir\gamblock-research.jks" -storetype JKS `
  -alias gamblock-research -keyalg RSA -keysize 2048 `
  -sigalg SHA256withRSA -validity 10000 `
  -dname "CN=Gamblock-AI Research, O=Gamblock-AI, C=ID"
```

For each keytool command, the expected prompts are:

1. `Enter keystore password` — create a strong password.
2. `Re-enter new password` — type the same password again.
3. `Enter key password` — press **Enter** to reuse the keystore password.

No characters or asterisks appear while entering passwords; that is normal.
Store each password in a password manager under separate entries named
`Gamblock Android Play Upload` and `Gamblock Android Research`. Record the
alias and file path in the same entry. Never save the password in `.env`, a
text file inside the repository, or a screenshot.

Check that the files exist without exposing passwords:

```powershell
Get-ChildItem $KeyDir
& $Keytool -list -keystore "$KeyDir\gamblock-play-upload.jks"
& $Keytool -list -keystore "$KeyDir\gamblock-research.jks"
```

`keytool` must be available through a JDK. If `Get-Command keytool` fails,
install/use JDK 17 from Android Studio or a trusted JDK distribution, then
open a new PowerShell window.

### Linux path (recommended for this project)

Open an existing terminal with **Ctrl+Alt+T**. Do not double-click a `.sh`
file or a command file: a terminal launched that way may close as soon as a
command fails. Run each numbered block below separately so an error remains
visible in the terminal.

First check that Java/keytool is available and create a private directory
outside the repository:

```sh
java -version
keytool -version
mkdir -p "$HOME/.config/gamblock-ai/release-keys"
chmod 700 "$HOME/.config/gamblock-ai/release-keys"
umask 077
export KEY_DIR="$HOME/.config/gamblock-ai/release-keys"
```

Now create the Play upload key. The command pauses for password prompts; that
is expected and can take a few seconds:

```sh
keytool -genkeypair -v \
  -keystore "$KEY_DIR/gamblock-play-upload.jks" -storetype JKS \
  -alias gamblock-play-upload -keyalg RSA -keysize 2048 \
  -sigalg SHA256withRSA -validity 10000 \
  -dname "CN=Gamblock-AI Play Upload, O=Gamblock-AI, C=ID"
```

Then create the separate Research key:

```sh
keytool -genkeypair -v \
  -keystore "$KEY_DIR/gamblock-research.jks" -storetype JKS \
  -alias gamblock-research -keyalg RSA -keysize 2048 \
  -sigalg SHA256withRSA -validity 10000 \
  -dname "CN=Gamblock-AI Research, O=Gamblock-AI, C=ID"
```

For **each** keytool command, expect these prompts:

1. `Enter keystore password` — create a strong password.
2. `Re-enter new password` — type the same password again.
3. `Enter key password for <alias>` — press **Enter** to reuse the keystore
   password, unless you intentionally recorded a separate key password.

Linux shows no characters or asterisks while a password is typed. That is
normal: type it carefully and press Enter. Save the two passwords immediately
in a password manager under `Gamblock Android Play Upload` and
`Gamblock Android Research`; also record the alias and the file path. Do not
put either password in the repository, `.env`, screenshots, or chat.

Confirm only that the files exist:

```sh
ls -l "$KEY_DIR"
```

If `keytool` is not found, install/use a JDK (Android Studio's bundled JDK is
fine), open a new terminal, and repeat the check. If a command reports an
error, the terminal should stay open; copy the error text instead of rerunning
the whole sequence blindly.

For the Windows pilot, use a CA-issued Authenticode code-signing certificate
with the Code Signing EKU and export it as a password-protected PFX. A
self-signed certificate is suitable only for an isolated internal VM; it does
not remove SmartScreen/Defender reputation warnings.

The backend README contains the authoritative commands for generating the
ES256 protection-grant private key and deriving the public
`PROTECTION_GRANT_TRUST_STORE_BASE64` value. The private PEM/DER stays in the
backend vault; only the public trust-store value is copied to client build
variables.

After `gh auth login -h github.com -p https -w`, set public repository
variables. These commands do not contain private key material:

```sh
APP_REPO="Gamblock-AI/Gamblock-AI-Apps"
gh variable set PROD_API_BASE_URL --repo "$APP_REPO" --body "https://api.gamblock-ai.com"
gh variable set WEB_BASE_URL --repo "$APP_REPO" --body "https://gamblock-ai.com"
gh variable set ENABLE_PRODUCTION_RELEASE --repo "$APP_REPO" --body "false"
gh variable set ENABLE_WINDOWS_PILOT_RELEASE --repo "$APP_REPO" --body "false"
gh variable set PROTECTION_GRANT_TRUST_STORE_BASE64 --repo "$APP_REPO" --body "$PROTECTION_GRANT_TRUST_STORE_BASE64"
gh variable set ANDROID_PLAY_KEY_ALIAS --repo "$APP_REPO" --env release-signing --body "gamblock-play-upload"
gh variable set ANDROID_RESEARCH_KEY_ALIAS --repo "$APP_REPO" --env release-signing --body "gamblock-research"
```

Upload private values directly from the temporary files or from shell prompts;
`gh` encrypts secret values locally before sending them:

```sh
base64 < "$KEY_DIR/gamblock-play-upload.jks" | tr -d '\n' |
  gh secret set ANDROID_PLAY_KEYSTORE_BASE64 --repo "$APP_REPO" --env release-signing --app actions
base64 < "$KEY_DIR/gamblock-research.jks" | tr -d '\n' |
  gh secret set ANDROID_RESEARCH_KEYSTORE_BASE64 --repo "$APP_REPO" --env release-signing --app actions

read -rsp 'Play keystore password: ' PLAY_PASSWORD; echo
printf '%s' "$PLAY_PASSWORD" | gh secret set ANDROID_PLAY_KEYSTORE_PASSWORD --repo "$APP_REPO" --env release-signing --app actions
printf '%s' "$PLAY_PASSWORD" | gh secret set ANDROID_PLAY_KEY_PASSWORD --repo "$APP_REPO" --env release-signing --app actions

read -rsp 'Research keystore password: ' RESEARCH_PASSWORD; echo
printf '%s' "$RESEARCH_PASSWORD" | gh secret set ANDROID_RESEARCH_KEYSTORE_PASSWORD --repo "$APP_REPO" --env release-signing --app actions
printf '%s' "$RESEARCH_PASSWORD" | gh secret set ANDROID_RESEARCH_KEY_PASSWORD --repo "$APP_REPO" --env release-signing --app actions
```

Upload the Windows PFX only to the `pilot-signing` environment:

```sh
PFX_PATH="/absolute/path/to/gamblock-pilot-signing.pfx"
base64 < "$PFX_PATH" | tr -d '\n' |
  gh secret set WINDOWS_PILOT_SIGNING_PFX_BASE64 --repo "$APP_REPO" --env pilot-signing --app actions
read -rsp 'Windows PFX password: ' WINDOWS_PFX_PASSWORD; echo
printf '%s' "$WINDOWS_PFX_PASSWORD" |
  gh secret set WINDOWS_PILOT_SIGNING_PFX_PASSWORD --repo "$APP_REPO" --env pilot-signing --app actions
```

Verify only names and metadata, never values:

```sh
gh variable list --repo "$APP_REPO"
gh variable list --repo "$APP_REPO" --env release-signing
gh secret list --repo "$APP_REPO" --env release-signing --app actions
gh secret list --repo "$APP_REPO" --env pilot-signing --app actions
```

## Android Play submission

Before creating an immutable `vMAJOR.MINOR.PATCH` tag:

- confirm the university organization owns the Play Console account and final
  package identity;
- host the current privacy policy and non-medical disclaimer on the public
  website;
- complete Data Safety from actual network payloads, not from marketing copy;
- complete the Mental/Behavioral Health declaration;
- submit the Accessibility declaration and a video showing the in-app
  disclosure, decline path, system enablement, one supported browser block, and
  Pattern Interrupt;
- provide reviewer credentials and keep the backend reviewer environment
  available;
- verify that the Play AAB contains no Research service implementation,
  Settings/package-installer package targets, or removal-interception strings.

Start with Play internal testing for the approved cohort. Testing tracks do not
waive Accessibility or health-policy review. If review rejects the core local
blocking action, stop the public submission and record the decision; do not
hide the behavior or silently ship a passive substitute.

## Android Research pilot

Research staff install the release-signed APK on dedicated devices, explain the
separate product, partner, and research consent boundaries, and guide the user
through Android's normal sideload and Restricted Settings screens. Do not
disable Play Protect or add broad device security exceptions.

Record the exact APK version, SHA-256, signing-certificate digest, device/OEM,
Android version, installer source, and every warning shown. The participant is
not promised irreversible protection: device administrators, recovery modes,
and OS-supported break-glass paths remain authoritative.

## Windows pilot

Provision only approved PCs/VMs. Install the dedicated pilot root and Trusted
Publisher certificate under administrator control, then verify the MSI's
publisher and SHA-256 before installation. Never import the pilot root on an
arbitrary personal/BYOD machine.

The MSI must install immutable application files under `Program Files`, put
mutable machine state under `ProgramData`, register SCM recovery, expose repair
and clean uninstall in Add/Remove Programs, and leave no service or executable
after removal. Participants normally use standard-user accounts. A signed
partner grant opens the normal maintenance path; the research administrator
retains break-glass uninstall.

Distinguish SmartScreen reputation warnings from Defender Antivirus detections.
For a concrete Defender detection, preserve the exact artifact/hash and submit
it through Microsoft's software-developer false-positive process. Never solve a
warning by disabling Defender globally.

## Release evidence gate

Archive, without browsing content:

- signature-verification output and SHA-256 manifests;
- Android permission/flavor audit and disclosure screenshots/video;
- Android 13–16 install, enable, reboot, update, decline, grant-expiry, and
  uninstall traces across the available OEM matrix;
- Windows clean-install, ACL, standard-user overwrite denial, SCM recovery,
  repair, upgrade, approved uninstall, admin break-glass, and removal traces;
- invalid-signature, wrong-device, wrong-action, excessive-TTL, clock rollback,
  restart, and key-rotation results on both native authorities.

Evidence may establish a reviewed pilot candidate. It does not change the
model's `evaluated: false` status or guarantee external store/reputation review.
