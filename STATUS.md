# STATUS — Toolchain Progress & Next Actions

This file records the **current, machine-specific status** of the Android / Flutter development toolchain.
It complements (but does not replace) the specification in `Project_Prompt.md`.

**Rule of thumb**
- `Project_Prompt.md` = what the system *should be*
- `STATUS.md` = what is *actually done right now*

---

## Snapshot

- **Last updated:** 2026-01-23
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

- Build & run (baseline) — **DONE**
  - `flutter run` builds, installs, and launches

---

### Firebase / Authentication (Section 6.5)

- Firebase project, OAuth, and Google Sign-In — **DONE**
- Web OAuth Client ID pinned and verified
- Interactive Google Sign-In succeeds reliably

---

### Authorization & Backend Integration (Section 6.6)

- Backend scaffold (FastAPI) — **DONE**
- Firebase Admin token verification — **DONE**
- Firestore allowlist enforcement — **DONE**
- 401 vs 403 semantics verified
- Root cause fixed:
  - Firestore field name mismatch (`Enabled` vs `enabled`)

- Token handling — **DONE**
  - Manual token copy eliminated (emulator path)
  - Flutter calls backend `GET /whoami` directly using a live Firebase ID token
  - Emulator reaches host backend via `http://10.0.2.2:8000`

Baseline success (backend):
```json
{"uid":"D0ir2ss1saXofBendf3zjoJdDGE3","email":"standket@gmail.com","project":"androiddev-toolchain","role":"admin","enabled":true}
```

Baseline success (Flutter → backend, emulator):
```text
[whoami] {uid: D0ir2ss1saXofBendf3zjoJdDGE3, email: standket@gmail.com, project: androiddev-toolchain, role: admin, enabled: true}
```

---

## Next Actions

1. Confirm Flutter → backend `/whoami` call on **physical device** (Pixel 6) using PC LAN IP base URL.
2. Capture final authorization notes in `docs/6_6_Authorization.md` (include schema, 401 vs 403 semantics, and case-sensitive field names).
3. Optional: add a small dev helper to start backend + emulator (PowerShell script) to reduce friction.

---

## Update Rules

- Update this file whenever a status changes
- Capture *why* something was fixed, not just *that* it changed
