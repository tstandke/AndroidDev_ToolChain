# STATUS — Toolchain Progress & Next Actions

This file records the **current, machine-specific status** of the Android / Flutter development toolchain.
It complements (but does not replace) the specification in `Project_Prompt.md`.

**Rule of thumb**
- `Project_Prompt.md` = what the system *should be*
- `STATUS.md` = what is *actually done right now*

---

## Snapshot

- **Last updated:** 2026-01-22
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

- Android Emulator — **DONE**
  - Emulator functional
  - `flutter run` installs and launches APK successfully

- Physical device (USB debugging) — **DONE (verified)**
  - Device used: Pixel 6
  - `flutter run` installs and launches in debug mode

---

### Reference Flutter App (`reference_app`)

- App creation — **DONE**
  - Generated via `flutter create`

- Android package name — **DONE**
  - Updated from `com.example.reference_app` → `com.toolchain.reference_app`
  - Verified in:
    - `android/app/build.gradle.kts`
    - Kotlin source path

- Build & run (baseline) — **DONE**
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
  - Present at: `reference_app/android/app/google-services.json`

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

- Firebase initialization in app — **DONE**
  - `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)` executed before any Auth calls

- Google provider enabled (Firebase Console) — **DONE**
  - Firebase Console → Authentication → Sign-in method → Google: Enabled

- Google Sign-In runtime integration — **DONE**
  - Interactive login succeeds
  - Account chooser appears
  - Firebase session established (`FirebaseAuth.instance.signInWithCredential` succeeds)
  - Verification output observed:
    - Selected account email displayed
    - Firebase user email displayed

- Web OAuth Client ID (serverClientId) — **DONE (pinned; exact match required)**
  - **kServerClientId (type-3 Web client ID):**
    - `883224591051-apnl4fdr2on5ar1d1pbhfk2fpoi0ldle.apps.googleusercontent.com`
  - Lessons learned: one-character mismatch (`l` vs `1`) caused repeated sign-in failures; do not OCR this value.

---

### Authorization & Backend Integration (Section 6.6)

This section captures the **exact working state** of Section 6.6 at pause time, so work can resume deterministically without re-debugging.

#### Backend Service (Local Development)

- Authorization backend scaffold — **IN PROGRESS**
  - Location: `backend/`
  - Framework: **FastAPI**
  - Runtime: **Python (venv-based)**
  - Entry point: `backend/main.py`

- Local startup (verified):
  ```powershell
  cd backend
  .\.venv\Scripts\Activate.ps1
  uvicorn main:app --reload
  ```

- Health endpoint — **DONE**
  - Endpoint: `GET /health`
  - Verified response:
    ```json
    {"status":"ok","project":"androiddev-toolchain"}
    ```

#### Firebase Admin SDK / GCP Context

- Firebase Admin initialization — **DONE**
  - Uses **Application Default Credentials (ADC)**
  - Project is pinned for local determinism (avoid wrong-project token verification):
    - `projectId = androiddev-toolchain`

- GCP / ADC alignment — **DONE**
  - `gcloud config set project androiddev-toolchain`
  - `gcloud auth application-default set-quota-project androiddev-toolchain`
  - Note: Multiple accounts are present; ADC login succeeded; access token printing works.

#### Authentication Enforcement (401 Semantics)

- Endpoint: `GET /whoami` — **DONE**
  - Missing/malformed token → **401**
  - Invalid/expired token → **401**
  - Valid Firebase ID token → proceeds to authorization stage
  - Verified: a reconstructed Firebase ID token returned `200 OK` with `uid` + `email`.

#### Authorization Model (Firestore Allowlist)

- Authorization source of truth — **DEFINED**
  - Firestore collection: `authz_users`
  - Document ID: Firebase `uid`
  - Required fields:
    - `enabled` (Boolean)
    - `role` (String)
    - `email` (String)

- Admin bootstrap document — **CREATED (needs validation)**
  - Collection: `authz_users`
  - Document ID: `D0ir2ss1saXofBendf3zjoJdDGE3`
  - Intended:
    - `enabled: true`
    - `role: "admin"`
    - `email: "standket@gmail.com"`
  - Firestore UI showed “Production mode?” prompt; doc was created.

#### Authorization Enforcement (403 Semantics)

- Backend enforcement — **DONE**
  - Authenticated but not allowlisted → **403**
  - Allowlisted but `enabled != true` → **403**
  - Allowlisted + enabled → **200**

- Current observed behavior — **BLOCKED (data-level)**
  - `GET /whoami` returns:
    ```json
    {"detail":"Not authorized (disabled)"}
    ```
  - Interpretation:
    - The allowlist document exists, but `enabled` is either missing, false, or stored as a non-boolean type (e.g., string).

#### Token Handling (Development Notes)

- Firebase ID tokens are short-lived (~1 hour). Re-testing after delays commonly yields **401 InvalidIdTokenError** due to expiration.
- Manual copy/paste from logs is error-prone due to log truncation and injected prefixes.
- Working approach (verified):
  - Flutter prints token in fixed-size chunks with indices.
  - PowerShell reconstructs token by stripping prefixes and concatenating chunk payloads.
  - Reconstructed token produced a **200 OK** response previously.

- Working evidence (prior):
  - `curl.exe -H "Authorization: Bearer <token>" http://127.0.0.1:8000/whoami` returned:
    ```json
    {"uid":"D0ir2ss1saXofBendf3zjoJdDGE3","email":"standket@gmail.com","project":"androiddev-toolchain"}
    ```

---

## Known Issues / Root Cause Analysis (Resolved)

- **Client ID transcription error (resolved)**
  - Symptom(s):
    - `No credential available`
    - `[28444] Developer console is not set up correctly`
  - Root cause:
    - Web Client ID in app did not match GCP “Web client” ID exactly (OCR/transcription error)
  - Fix:
    - Copy/paste Web Client ID from Google Auth Platform → Clients → Web client
    - Confirm exact match character-for-character

---

## Next Actions (Priority)

1. **Section 6.6 — Fix Firestore allowlist doc field types**
   - Confirm `authz_users/D0ir2ss1saXofBendf3zjoJdDGE3.enabled` is a **Boolean true** (not `"true"`).
   - Re-test with a **fresh** Firebase ID token; expect `200 OK`.

2. **Mark Section 6.6 baseline Authorization as DONE** once `200 OK` is confirmed for an allowlisted admin.

3. **Eliminate manual token copy**
   - Implement Flutter → backend `/whoami` call using the live ID token.

4. Optionally, capture final working auth flow notes under `docs/6_6_Authorization.md` (include 401 vs 403 semantics and bootstrap policy).

---

## Update Rules

- Update this file whenever a status changes
- Keep entries concise and factual
- Capture *why* something was blocked or fixed, not just *that* it changed

