# AndroidDev ToolChain — Project Prompt & Reproduction Guide

## 1. Purpose (Why this document exists)
This document is the **single authoritative prompt** that can be handed to an AI assistant (or engineer) to:
- Recreate an Android application development workstation from scratch (Windows-first)
- Maintain architectural, security, and tooling consistency
- Avoid rediscovering prior decisions and configuration pitfalls

It is intentionally concise, modular, and update-friendly.

---

## 2. One-Paragraph System Summary (High-Level)
This project defines a **Windows-based Android development toolchain** suitable for building, running, testing, signing, and releasing Android applications. It standardizes installation and configuration of **Git/GitHub**, **Android Studio + Android SDK**, **JDK**, **Gradle**, **device/emulator workflows**, and (when applicable) **Flutter** and **Firebase/GCP** integration. It also defines verification commands, environment validation, secure credential handling (keystores, tokens), and CI/CD via GitHub Actions, so the toolchain can be reproduced deterministically on new machines.

---

## 3. Technology Stack (Pinned Choices)

### Workstation Platform
- Windows 11 (primary target)
- Windows Terminal (preferred)
- PowerShell 7 (preferred) or Windows PowerShell 5.1 (acceptable)

### Source Control
- Git for Windows (installed and on PATH)
- GitHub (public repos allowed; private repos optional)
- GitHub CLI `gh` (recommended)

### Android Tooling
- Android Studio (stable channel)
- Android SDK Platform Tools (adb/fastboot)
- Android SDK Build Tools (pinned per project)
- Android Emulator (AVD Manager via Android Studio)
- Gradle (via wrapper; do not install global Gradle unless explicitly required)

### Java Tooling
- JDK (prefer the JDK bundled with Android Studio unless a project requires a specific external JDK)
- JAVA_HOME set only if required by tooling; prefer Android Studio embedded JDK when possible

---

## 4. Git Tooling (Source Control Foundation)

### What Git Is and Why It Is Required
Git is a **distributed version control system** used to track changes to files over time. In this toolchain, Git serves as the foundational mechanism for recording all source code and documentation changes, enabling safe experimentation via branches, supporting reproducibility by preserving full history, and enabling collaboration and review workflows.

### Git vs GitHub
- **Git** is the version control tool installed on your machine.
- **GitHub** is a hosted service that stores Git repositories and adds collaboration, access control, and automation.

Git must be installed first. GitHub access is layered on top.

### 4.1 Git Installation Check
Command:
```
git --version
```

Expected result:
```
git version 2.x.y.windows.z
```

### 4.2 Git Installation (If Missing)
Install **Git for Windows** using the official installer. After installation, close and reopen PowerShell, then re-run `git --version`.

### 4.3 GitHub CLI (`gh`) Installation Check
Command:
```
gh --version
```

If not recognized, install using:
```
winget install --id GitHub.cli
```

Close and reopen PowerShell after installation.

### 4.4 GitHub Authentication
Authenticate once per machine:
```
gh auth login
```

Verify:
```
gh auth status
```

Tooling is considered complete only when `git --version`, `gh --version`, and `gh auth status` all succeed.

---

## 5. Security Model (Non-Negotiable Principles)
1. Secrets are never committed.
2. Prefer least-privilege credentials.
3. Use secure credential storage.
4. Release signing keys are protected and backed up.
5. CI/CD secrets are managed via GitHub Secrets.

---

## 6. Canonical Toolchain Setup Flow
1. Install Git and GitHub CLI
2. Install Android Studio and SDKs
3. Configure environment
4. Verify emulator/device workflow
5. Scaffold projects
6. Configure signing
7. Configure CI/CD

---

## 7. Validation Commands (Minimum Acceptance)
- `git --version`
- `gh --version`
- `adb version`
- `adb devices`
- `./gradlew assembleDebug`

---

## 8. Repository Structure
```
repo_root/
  docs/
  scripts/
  templates/
  Project_Prompt.md
  README.md
  FILE_INDEX.md
```

---


---

## Repository Orientation (Required Reading)

After reviewing this document, **also review the following two files** to fully understand how this repository is intended to be used and evolved:

- **README.md** — Usage, workflow, and helper scripts  
  https://github.com/tstandke/AndroidDev_ToolChain/blob/main/README.md

- **FILE_INDEX.md** — Authoritative map of repository structure, file roles, and update rules  
  https://github.com/tstandke/AndroidDev_ToolChain/blob/main/FILE_INDEX.md

These documents are part of the canonical documentation spine:
- `Project_Prompt.md` defines intent and decisions
- `README.md` defines usage and operational workflow
- `FILE_INDEX.md` defines structure and purpose

AI assistants should treat all three together as the source of truth.


## 9. Lessons Learned / FAQ
- Always use Gradle wrapper.
- CLI builds must succeed before proceeding.
- Treat signing keys as production secrets.
- Document failures immediately.

