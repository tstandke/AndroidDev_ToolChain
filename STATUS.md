# STATUS — Toolchain Progress & Next Actions

This file records the **current, machine-specific status** of the Android / Flutter development toolchain.
It complements (but does not replace) the specification in `Project_Prompt.md`.

**Rule of thumb**
- `Project_Prompt.md` = what the system *should be*
- `STATUS.md` = what is *actually done right now*

---

## Snapshot

- **Last updated:** 2026-01-16
- **Machine:** Tim-PC
- **Primary shell:** PowerShell
- **OS:** Windows 11 Home (25H2)

---

## Completion Legend

- **DONE** — Installed, configured, and verified
- **IN PROGRESS** — Work started but not verified
- **BLOCKED** — Cannot proceed due to an external issue
- **NOT STARTED** — Not yet attempted

---

## Toolchain Status

### Source Control

- GitHub identity — **DONE**
  - Username: `tstandke`
  - Primary accounts in use:
    - `standket@gmail.com` (Firebase / Google Cloud ownership)
    - `tstandke@msoltec.com` (secondary)
  - Credential storage: **NordPass**

- Git for Windows — **DONE**
  - Verify: `git --version`
  - Result: `2.52.0.windows.1`

- GitHub CLI (`gh`) — **DONE**
  - Verify: `gh auth status`
  - Result: authenticated as `tstandke`

---

### Flutter Toolchain

- Flutter SDK — **DONE**
  - Channel: `stable`
  - Version: `3.38.7`
  - Install path: `C:\src\flutter`
  - Verified via `flutter --version`

- Flutter Doctor — **DONE**
  - Result: Android toolchain healthy
  - Notes:
    - Android licenses accepted
    - Visual Studio missing (Windows desktop only; **out of scope**)

---

### Android Tooling

- Android Studio — **DONE**
  - Stable channel
  - Bundled JBR (OpenJDK 17) in use

- Android SDK — **DONE**
  - SDK path: `C:\Users\Tim\AppData\Local\Android\Sdk`
  - Platform: `android-36`
  - Build-tools: `36.0.0`
  - Emulator functional

- Android Emulator — **DONE**
  - Target: `sdk gphone64 x86_64`
  - `flutter run` installs and launches APK successfully

- Physical device (USB debugging) — **IN PROGRESS**
  - Not required for current work

---

### Reference Flutter App (`reference_app`)

- App creation — **DONE**
  - Generated via `flutter create`

- Android package name — **DONE**
  - Updated from `com.example.reference_app` → `com.toolchain.reference_app`
  - Verified in:
    - `android/app/build.gradle.kts`
    - Kotlin source path

- Build & run (no auth) — **DONE**
  - `flutter run` builds, installs, and launches

---

### Firebase / Authentication (Section 6.5)

- Firebase CLI — **DONE**
  - Version: `14.4.0`

- FlutterFire CLI — **DONE**
  - Version: `1.3.1`

- Firebase project — **DONE**
  - Project name: **AndroidDev-ToolChain**
  - Project ID: `androiddev-toolchain`

- Firebase apps registered — **DONE**
  - Android app:
    - Package: `com.toolchain.reference_app`
    - App nickname: `toolchain_ref_app`
  - iOS app auto-registered by FlutterFire (not yet used)

- `google-services.json` — **DONE**
  - Downloaded *after* SHA-1 fingerprint was added
  - Placed at: `reference_app/android/app/google-services.json`

- SHA-1 fingerprint — **DONE**
  - Debug keystore SHA-1 added in Firebase Console
  - Verified visible under Android app settings

- FlutterFire configuration — **DONE**
  - `flutterfire configure` completed
  - `lib/firebase_options.dart` generated

- Firebase dependencies — **DONE**
  - `firebase_core`
  - `firebase_auth`
  - `google_sign_in`

- Google Sign-In provider — **DONE (Console-side)**
  - Enabled in Firebase Authentication → Sign-in method

- Google Sign-In runtime integration — **BLOCKED**
  - App builds and runs
  - Google sign-in UI launches
  - **Error at runtime:**
    ```
    GoogleSignInException(code: unknownError,
    No credential available: No credentials available)
    ```

---

## Known Issues / Root Cause Analysis (So Far)

- **google_sign_in v7.x API change**
  - Old `signIn()` flow removed
  - Requires:
    - `GoogleSignIn.instance.initialize(serverClientId: ...)`
    - `authenticate()`
    - Listening to `authenticationEvents`

- **OAuth client mismatch suspected**
  - Android OAuth client (type 1) present
  - Web / server OAuth client (type 3) present
  - Runtime error indicates **no credential resolved on device**

- **Most likely remaining causes** (to verify next session):
  1. OAuth client not fully propagated after recent changes (console-side delay)
  2. Wrong client ID used as `serverClientId` (must be type 3, same project)
  3. Cached Play Services / emulator state
  4. Emulator requires cold boot after OAuth changes

---

## Recommended First Steps for Next Session

1. Cold-boot Android emulator
2. Clear emulator Google Play Services data (if needed)
3. Reconfirm **only one** Firebase project is active
4. Reconfirm OAuth client IDs in Google Cloud Console
5. Verify `serverClientId` matches **type 3** client exactly
6. Retry sign-in without further code changes

---

## Next Actions (Priority)

1. Resolve Google Sign-In credential issue (Section 6.5)
2. Confirm successful Firebase user creation
3. Capture final working configuration in `6_5_Identity_Authentication_Setup.md`
4. Commit updated `STATUS.md` to GitHub

---

## Update Rules

- Update this file whenever a status changes
- Keep entries concise and factual
- Capture *why* something is blocked, not just *that* it is blocked

