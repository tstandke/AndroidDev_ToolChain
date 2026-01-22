# Project_Prompt — Android / Flutter Toolchain (Authoritative Specification)

## 1. Purpose

This document is the **authoritative specification** for recreating, extending, and resuming work on this repository without rediscovering past decisions.

It is explicitly designed to be handed to an AI assistant (LLM) at the start of a new session so that work can continue deterministically and correctly.

---

## 2. System Summary & Canonical Reference Application

This project defines a **Windows-first, Flutter-based mobile application toolchain**, targeting **Android initially** and **iOS in the future**, with **Firebase-backed authentication**, **server-side authorization**, **local biometric session unlock**, and **Google Cloud Platform (GCP)** infrastructure.

The repository encodes both:

- The **intended system design** (what the toolchain and application stack *should be*), and  
- The **actual current state** (what is installed, verified, and known to work on a specific machine),

so that setup, validation, and continuation can occur **deterministically**, without rediscovering prior decisions.

### Canonical Reference Application (Toolchain Smoke Test)

This repository includes a **minimal, canonical Flutter reference application** located at:

- `reference_app/`

The reference application exists solely to **validate the toolchain end-to-end** and to detect when **toolchain updates** (Flutter, Android SDK, Gradle, Android Studio, Firebase tooling) introduce breaking changes.

The reference application is intentionally minimal and is used to validate:

- Flutter → Android build execution (`flutter run`)
- Android emulator and/or physical device deployment
- Firebase Authentication (Google Sign-In)
- Server-side authorization enforcement (post-authentication)
- Local biometric unlock for session convenience  
  (biometrics are **never** an identity authority)

### Non-Goals

The reference application is **not** intended to:

- Become a production application
- Accumulate business logic or domain features
- Serve as a UI/UX exemplar
- Replace real application repositories

Its sole purpose is to make the toolchain **provable, repeatable, and diagnosable** across machines, developers, and AI-assisted sessions.

---


## 3. Technology Stack (Authoritative & Pinned)

> This section defines the **complete, end-to-end toolchain** required to build, authenticate, authorize, and operate **cross-platform mobile applications**, with Android as the initial execution target and iOS as a future extension.  
> Any deviation from this stack must be explicitly recorded.

### 3.1 Workstation Platform

- **Operating System:** Windows 11  
- **Primary Shell:** PowerShell  
- **Package Management:** winget (preferred), manual installers as required  
- **Source Control Client:** Git for Windows  

---

### 3.2 Source Control & Repository Management

- **Git Provider:** GitHub  
- **Git Identity:** recorded in `STATUS.md`  
- **Credential Storage:** NordPass  
- **Repo Update Discipline:**  
  - Canonical files updated via narrow helper scripts in `/scripts`  
  - One logical change per commit where feasible  

---

### 3.3 Flutter Development Tooling (REQUIRED)

- **Flutter SDK**
  - Stable channel
  - Installed outside the project workspace
  - Version recorded in `STATUS.md`
- **Flutter Toolchain Verification**
  - `flutter doctor`
  - Android toolchain must report **no blocking issues**
- **Flutter Project Model**
  - Flutter is the primary application framework
  - Platform-specific code (Android / iOS) is generated and managed by Flutter

> **Principle:** Flutter is the application layer.  
> Android and iOS tooling support Flutter; they are not the primary frameworks.

---

### 3.4 Android Development Tooling

- **Android Studio:** Stable channel  
- **Android SDK Components**
  - SDK Platform(s)
  - SDK Platform Tools (`adb`)
  - Build Tools (version pinned per project)
- **Android Emulator (AVD)**
  - x86_64 system images
  - Hardware acceleration enabled
- **Physical Device Support**
  - USB debugging enabled
  - OEM USB drivers installed if required

---

### 3.5 Java / Build Tooling

- **Java Development Kit (JDK)**
  - Version required by pinned Android Gradle Plugin
- **Gradle**
  - Wrapper-based (`gradlew`)
  - No reliance on system Gradle
- **Build Verification**
  - Android builds executed via Flutter
  - `flutter run`, `flutter build apk`

---

### 3.6 Identity, Authentication, and Authorization (REQUIRED)

#### Authentication — Client (Flutter)

- **Firebase Authentication**
  - Google Sign-In enabled
  - Flutter Firebase Auth SDK
- **Platform Configuration**
  - `google-services.json` (Android)
  - iOS configuration captured later
- **Signing Certificates**
  - Debug and release SHA-1 / SHA-256 fingerprints registered in Firebase

#### Authentication — Server

- **ID Token Verification**
  - Firebase ID tokens verified server-side using Admin SDK
  - No trust placed in client-side claims

#### Authorization — Server-Side Enforcement

- **Authorization Source of Truth**
  - Centralized (e.g., Firestore roles / allowlists)
- **Authorization Rules**
  - Evaluated server-side after authentication
  - Client UI must not determine access

> **Rule:** Authentication proves identity.  
> Authorization determines permission.  
> Authorization is never enforced solely on the client.

---

### 3.7 Firebase & Google Cloud Platform

- **Firebase Project**
  - Created explicitly for the application
  - Linked to a Google Cloud project
> **Note (important):** Every Firebase project is backed by (and linked to) a Google Cloud project.
> Firebase may create this GCP project automatically during Firebase project creation.
> OAuth client IDs used for Google Sign-In live in the linked GCP project (Google Cloud Console → APIs & Services → Credentials),
> even if you never manually “used GCP.”
- **Google Cloud Platform (GCP)**
  - Required for:
    - Firebase backend services
    - Firestore
    - Cloud Run / Functions (if used)
    - App Check providers
- **IAM & Service Accounts**
  - Least-privilege access
  - Ownership documented
- **Secrets Management**
  - Google Secret Manager (recommended)

---

### 3.8 App Attestation & Abuse Protection (Recommended)

- **Firebase App Check**
  - Provider: Play Integrity API (Android)
- **Debug vs Release**
  - Debug tokens permitted only in development
  - Enforcement required for production

---

### 3.9 Supporting Developer Tooling

- **Google Cloud SDK (`gcloud`)**
- **Firebase CLI**
- **FlutterFire CLI**

---

## 4. Repository Navigation (Required Reading)

This file is the entry point. The following files must be consulted:

- **README.md**  
  Orientation and instructions for AI-assisted usage  
  https://github.com/tstandke/AndroidDev_ToolChain/blob/main/README.md

- **FILE_INDEX.md**  
  Canonical index of repository contents  
  https://github.com/tstandke/AndroidDev_ToolChain/blob/main/FILE_INDEX.md

- **STATUS.md**  
  Machine-specific, current completion state  
  https://github.com/tstandke/AndroidDev_ToolChain/blob/main/STATUS.md

---

## 5. AI Collaboration Rules

When this document is provided to an AI assistant, the AI must operate as a **state-aware collaborator**, not a stateless chatbot.

### 5.1 General Rules

- Treat this file (`Project_Prompt.md`) as the **source of truth**
- Read all linked canonical documents before proposing actions:
  - `README.md`
  - `FILE_INDEX.md`
  - `STATUS.md`
- Follow the canonical toolchain flow in Section 6
- Prefer updating canonical repository files over chat-only advice
- Propose structured prompts, helper scripts, or documentation when reuse is likely

---

### 5.2 Documentation Drift Watch (Required)

The AI must actively monitor for **documentation drift** and explicitly prompt when canonical files should be updated.

#### Triggers for updating `STATUS.md` (current state)

Prompt to update `STATUS.md` when any of the following occur:

- A tool is installed, upgraded, removed, or reconfigured  
  (e.g., Flutter, Android Studio, SDKs, Git, gh)
- A verification command is run with meaningful output  
  (e.g., `flutter doctor`, `adb devices`, build success/failure)
- A step in Section 6 transitions state  
  (`NOT STARTED` → `IN PROGRESS` → `DONE`)
- Work is performed on a different machine, OS, or shell environment

---

#### Triggers for updating `FILE_INDEX.md` (repository inventory)

Prompt to update `FILE_INDEX.md` when any of the following occur:

- A new file or directory is added that is intended to persist
- Any file is renamed, moved, or deleted
- A new canonical document or repeat-use guide is created
- A new step guide is added under `docs/`
  (e.g., `6_3_*.md`, `auth/*.md`, `ci/*.md`)

---

#### Triggers for updating `README.md` (repo usage)

Prompt to update `README.md` when any of the following occur:

- The workflow for using the repo with an AI assistant changes
- Entry-point expectations change (e.g., Project_Prompt usage)
- Directory conventions change (`docs/`, `scripts/`, etc.)
- A new user-facing setup or operational workflow is introduced

---

### 5.3 Prompting Behavior Requirements

When a trigger condition is met, the AI must explicitly state:

- **Which file** should be updated (`STATUS.md`, `FILE_INDEX.md`, or `README.md`)
- **Why** the update is needed (which trigger was hit)
- **What the minimal change** should be

Additional rules:

- Prefer **minimal, single-purpose commits**
- If uncertainty exists, ask for confirmation before updating
- Do not allow canonical documents to silently drift out of sync

---

### 5.4 Priority Rule

If documentation and implementation disagree:

> **Update the documentation first, then proceed with implementation.**

This ensures the repository remains resumable and deterministic across sessions and AI assistants.

---

## 6. Canonical Toolchain Setup Flow

> This section defines the **required sequence** for setting up the toolchain.  
> Steps must be completed in order unless explicitly noted.

### 6.1 Repository & Source Control

1. Install and verify Git for Windows  
2. Authenticate with GitHub  
3. Clone repository and verify working tree  
4. Validate helper scripts (`GitUpdate-*.ps1`)  

**Record results in:** `STATUS.md`

---

### 6.2 Flutter Toolchain Installation

1. Install Flutter SDK (stable)  
2. Add Flutter to PATH  
3. Run `flutter doctor`  
4. Resolve all Android blocking issues  

**Record results in:** `STATUS.md`

---

### 6.3 Android Development Environment

1. Install Android Studio  
2. Launch and verify baseline startup  
3. Install required SDK components  
4. Configure emulator (AVD)  
5. Verify `adb` connectivity  

**Record results in:** `STATUS.md`

---

### 6.4 Flutter + Android Build Verification (Canonical Reference Application)

This step validates that the Android / Flutter toolchain can successfully
**build, deploy, and run a real Flutter application** using the canonical
reference app defined by this repository.

The purpose of this step is to confirm that toolchain components
(Flutter, Android SDK, Gradle, emulator/device, and supporting tools)
work together correctly on the current machine.

The canonical reference application is located at:

- `reference_app/`

---

#### Procedure

1. Change directory into the reference application:
   ```powershell
   cd reference_app
   ```

2. Fetch Flutter dependencies:
   ```powershell
   flutter pub get
   ```

3. Run the application on an Android emulator or connected device:
   ```powershell
   flutter run
   ```

4. Verify the following:
   - Gradle build completes successfully
   - The application installs and launches on the target device/emulator
   - Debug output appears in the console
   - Hot reload functions as expected

---

#### Interpretation

- Success in this step confirms that the **Android / Flutter toolchain is functional**.
- Failure at this step, especially after toolchain updates, indicates a **toolchain regression** rather than an application defect.
- This step is intentionally performed using the **canonical reference application**, not a production or experimental app.

---

#### Scope and Non-Goals

- This step does **not** validate application feature completeness.
- UI/UX quality is explicitly out of scope.
- The reference application exists solely to validate and diagnose the toolchain.

---

**Record results in:** `STATUS.md`


---

### 6.5 Identity & Authentication Setup

1. Create Firebase project  
2. Link to Google Cloud project  
3. Enable Firebase Authentication  
4. Configure Google Sign-In  
5. Register Android app  
6. Add SHA-1 / SHA-256 fingerprints  
7. Configure Flutter Firebase Auth  
8. Verify interactive sign-in  

#### Verification Checklist (Firebase ↔ GCP linkage)
This checklist prevents a common failure mode where authentication fails due to mismatched Google project context.

**A) Confirm you are in the correct Firebase project**
- Firebase Console → select the project
- Verify **Project ID** matches expected (e.g., `androiddev-toolchain`)

**B) Confirm which Google account owns/has access**
- Ensure you are logged into the same Google identity used to create the Firebase project.
- If the Firebase project is not visible under the current login, you are in the wrong Google identity.

**C) Confirm linked GCP project from Firebase**
- Firebase Console → Project settings → General
- Find the linked Google Cloud project
- Click **“View in Google Cloud Console”** (use this link to avoid guessing)

**D) Confirm OAuth clients exist in the linked GCP project**
- Google Cloud Console (from the link above) → APIs & Services → Credentials
- Under “OAuth 2.0 Client IDs”, confirm:
  - **Android client** exists for package `com.toolchain.reference_app` and includes the correct SHA-1
  - **Web application client** exists (often labeled “Web client (auto created by Google Service)”)

**E) Confirm app uses the correct Web Client ID**
- The `serverClientId` used in the app must match the **Web application** Client ID (ends with `.apps.googleusercontent.com`)
- Using the Android client ID or a Web client ID from another project can cause:
  - `No credential available`
  - `[28444] Developer console is not set up correctly`

**F) Propagation note**
- OAuth/SHA changes may take time to propagate.
- If sign-in fails immediately after console changes:
  - wait briefly, retry, and cold-boot the emulator.

#### Lessons Learned (reference_app: Web Client ID must be exact)
- **Root cause encountered:** A one-character transcription error in the Web Client ID (`l` vs `1`, and one missing `l`) caused repeated Google Sign-In failures and misleading errors.
- **Non-negotiable rule:** The Web Client ID must match **character-for-character**. Even a single character mismatch breaks token issuance.
- **Where to source the value:** Google Cloud Console → Google Auth Platform → Clients → **Web client (auto created by Google Service)** → copy the Client ID that ends with `.apps.googleusercontent.com`.
- **Do not OCR this value** from screenshots. Copy/paste from the console whenever possible.
- **Pinned value (known-good for this repo’s current Firebase/GCP project):**
  - `883224591051-apnl4fdr2on5ar1d1pbhfk2fpoi0ldle.apps.googleusercontent.com`
- **Important:** If the Firebase/GCP project is recreated, the Web Client ID will change. If authentication breaks after project recreation, re-run the checklist and re-pin the new value.

**Record results in:** `STATUS.md`

---

### 6.6 Authorization & Backend Integration

> Precondition: Section 6.5 is **DONE** and interactive Google Sign-In succeeds reliably.
> Authorization work begins only after authentication is confirmed stable.

1. Define authorization model
   - Decide the server-side source of truth (e.g., Firestore allowlist, roles, groups)
   - Define minimum fields (e.g., `users/{uid}: { role, enabled, createdAt, updatedAt }`)
   - Define expected denial behavior (401 vs 403) for unauthenticated vs unauthorized

2. Verify ID tokens server-side
   - Client must present Firebase ID token to backend (e.g., `Authorization: Bearer <token>`)
   - Backend verifies token using Firebase Admin SDK
   - Backend rejects missing/invalid/expired tokens (401 Unauthorized)

3. Enforce authorization rules (server-side)
   - After token verification, resolve caller identity (UID, email, claims)
   - Lookup authorization status/role in Firestore (or other source)
   - Reject unauthorized users (403 Forbidden)
   - Return only authorized data/actions

4. Validate rejection paths (test cases)
   - No token → 401
   - Invalid token → 401
   - Valid token but not allowlisted → 403
   - Valid token and allowlisted → success
   - Optional: revoked/disabled user → 403 (or 401 depending on policy)

**Record results in:** `STATUS.md`

---

### 6.7 App Attestation & Hardening

1. Enable Firebase App Check  
2. Configure Play Integrity  
3. Validate debug vs release behavior  
4. Enforce App Check  

**Record results in:** `STATUS.md`

---

### 6.8 Automation & CI (Optional / Later)

1. Baseline GitHub Actions  
2. Flutter build verification  
3. Android artifact generation  

---

## 7. Completion Criteria

The toolchain is complete only when:

- Flutter toolchain is verified
- Android execution is validated
- Authentication works end-to-end
- Authorization is enforced server-side
- Attestation is active for production paths

---

## 8. Maintenance Rule

If this file, `STATUS.md`, or `FILE_INDEX.md` becomes outdated,  
**update the documentation first**, then proceed with implementation.
