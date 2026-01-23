# Project_Prompt — Android / Flutter Toolchain (Authoritative Specification)

## 1. Purpose

This document is the **authoritative specification** for recreating, extending, and resuming work on this repository **without rediscovering past decisions**.

It is explicitly designed to be handed to an **AI assistant (LLM)** or a human developer at the start of a new session so that work can continue **deterministically, correctly, and auditable across sessions**.

---

## 1.1 AI Usage Model (Required Reading)

This repository is designed for **stateful continuation**, not stateless chat assistance.

An AI assistant operating with this repository **must**:

- Treat `Project_Prompt.md` as the **authoritative contract**
- Treat `STATUS.md` as the **current execution checkpoint**
- Never assume a step is complete unless explicitly marked **DONE**
- Resolve ambiguity by consulting `STATUS.md` before proposing new actions
- Prefer documentation updates over speculative fixes
- Classify failures *before* proposing remediation

Any advice that contradicts a canonical document is invalid.

---

## 2. System Summary & Canonical Reference Application

This project defines a **Windows-first, Flutter-based mobile application toolchain**, targeting **Android initially** and **iOS in the future**, with:

- Firebase-backed authentication
- Server-side authorization
- Local biometric session unlock
- Google Cloud Platform (GCP) infrastructure

The repository encodes both:

- The **intended system design** (what the stack *should be*), and
- The **actual current state** (what is installed and verified on a specific machine),

so that setup, validation, and continuation can occur **deterministically**, without rediscovering prior decisions.

### Canonical Reference Application (Toolchain Smoke Test)

A **minimal Flutter reference application** is located at:

- `reference_app/`

Its sole purpose is to validate the toolchain end-to-end and detect regressions caused by:

- Flutter upgrades
- Android SDK / Gradle changes
- Firebase tooling changes

The reference app validates:

- Flutter → Android builds (`flutter run`)
- Emulator and physical device deployment
- Firebase Authentication (Google Sign-In)
- Server-side authorization enforcement
- Local biometric unlock (never identity authority)

### Non-Goals

The reference application is **not** intended to:

- Become a production application
- Accumulate business logic
- Serve as a UI/UX exemplar
- Replace real application repositories

---

## 3. Technology Stack (Authoritative & Pinned)

### 3.1 Workstation Platform

- **OS:** Windows 11
- **Shell:** PowerShell
- **Package Manager:** winget (preferred)
- **Source Control Client:** Git for Windows

---

### 3.2 Source Control & Repository Management

- **Git Provider:** GitHub
- **Git Identity:** recorded in `STATUS.md`
- **Credential Storage:** NordPass
- **Commit Discipline:** one logical change per commit where feasible

---

### 3.3 Flutter Development Tooling (REQUIRED)

- **Flutter SDK**
  - Stable channel
  - Installed outside the repo
  - Version recorded in `STATUS.md`
- **Verification**
  - `flutter doctor` must show no Android blocking issues

> Principle: Flutter is the application layer; Android/iOS tooling supports Flutter.

---

### 3.4 Android Development Tooling

- Android Studio (stable)
- Android SDK (platforms, build-tools, platform-tools)
- Android Emulator (x86_64, HW accel)
- Physical device support (USB debugging)

---

### 3.5 Java / Build Tooling

- JDK version compatible with Android Gradle Plugin
- Gradle via wrapper only (`gradlew`)
- Builds executed through Flutter

---

### 3.6 Identity, Authentication, and Authorization

#### Authentication — Client
- Firebase Authentication
- Google Sign-In enabled
- Correct Web OAuth Client ID required

#### Authentication — Server
- Firebase ID token verification via Admin SDK
- No trust placed in client-side claims

#### Authorization — Server-Side
- Centralized source of truth (Firestore allowlist / roles)
- Authorization enforced **only** server-side

Rule:
Authentication proves identity.  
Authorization determines permission.

---

### 3.7 Firebase & Google Cloud Platform

- Firebase project linked to GCP project
- OAuth clients managed in GCP Console
- Firestore as authorization datastore
- IAM with least privilege

---

### 3.8 App Attestation & Abuse Protection (Recommended)

- Firebase App Check
- Play Integrity (Android)
- Debug vs release enforcement

---

### 3.9 Supporting Tooling

- Google Cloud SDK (`gcloud`)
- Firebase CLI
- FlutterFire CLI

---

### 3.10 Python Runtime (REQUIRED)

- Python 3.11+
- Local `.venv` per backend
- No global installs

> Note: All client → backend communication assumes correct LAN routing, firewall rules, and backend interface binding. See `docs/6_6_Authorization.md` for authoritative networking assumptions.

---

## 4. Repository Navigation (Required Reading)

- `README.md` — AI-assisted usage orientation
- `FILE_INDEX.md` — Canonical inventory
- `STATUS.md` — Machine-specific execution state

---

## 5. AI Collaboration Rules

### 5.1 General Rules

- Treat canonical docs as source of truth
- Read linked docs before proposing actions
- Prefer updating repo files over chat-only advice

---

### 5.2 Failure Classification Rule (REQUIRED)

Before proposing fixes, classify failures:

- Build failures → toolchain/environment
- Sign-in failures → authentication (6.5)
- 401 responses → token/verification
- 403 responses → authorization policy/data
- Timeouts → networking/firewall/VPN/binding

Do not mix categories.

---

### 5.3 Documentation Drift Watch

Prompt updates when:

- Tools change
- Verification output is observed
- Step state changes
- New canonical files are added

Always state:
- Which file
- Why
- Minimal change required

---

### 5.4 Priority Rule

If documentation and implementation disagree:

**Update documentation first, then proceed.**

---

## 6. Canonical Toolchain Setup Flow

### 6.1–6.5
Follow steps exactly as defined in prior versions.  
Record all results in `STATUS.md`.

---

### 6.6 Authorization & Backend Integration

**All schema, workflow, diagnostics, and invariants for this section are locked in:**

```
docs/6_6_Authorization.md
```

Any advice or implementation that contradicts that document is invalid.

Precondition:
- Section 6.5 authentication is **DONE**

Record results in `STATUS.md`.

---

### 6.7 App Attestation & Hardening

Enable App Check and enforce production paths.

---

## 7. Completion Criteria

A step is complete **only when**:

- Verification is performed
- Evidence is observed
- `STATUS.md` is updated

---

## 8. Maintenance Rule

If any canonical document is outdated:

**Update documentation first, then proceed.**
