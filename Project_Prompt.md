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
---

## Repository Navigation (Required Reading)

This document (`Project_Prompt.md`) is the **entry point** for understanding and reproducing this repository.

After reading it, **also review the following files** to fully understand usage, structure, and current completion state:

- **README.md** — usage, workflow, and helper scripts  
  https://github.com/tstandke/AndroidDev_ToolChain/blob/main/README.md

- **FILE_INDEX.md** — authoritative map of repository contents, file roles, and update rules  
  https://github.com/tstandke/AndroidDev_ToolChain/blob/main/FILE_INDEX.md

- **STATUS.md** — current completion state, verification results, blockers, and next actions  
  https://github.com/tstandke/AndroidDev_ToolChain/blob/main/STATUS.md

Together, these files form the **canonical documentation spine**:
1. `Project_Prompt.md` — intent, pinned decisions, and reproduction steps
2. `README.md` — operational usage and helper tooling
3. `FILE_INDEX.md` — structure, purpose, and update rules
4. `STATUS.md` — what is actually done, and what is next

AI assistants should treat this spine as the source of truth, and prefer updating it over repeating guidance in chat.


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

## AI Collaboration Hint (Author Preference)

When assisting with this repository, the author prefers **prompt-style documents** like this one to be *created, refined, and extended proactively*.

Specifically:
- When a new workflow, tool, or recurring process emerges, **propose a structured prompt or companion document** (similar to `Project_Prompt.md`, `STATUS.md`, or helper scripts).
- Favor **explicit, reusable prompts** over ad-hoc explanations.
- When in doubt, suggest creating a small, focused Markdown file plus a narrow PowerShell update helper.

---

## AI Maintenance Hint (Staleness Prevention)

When assisting with this repository, the AI should **actively watch for documentation drift**.

Specifically:
- If guidance, commands, or workflows are discussed that would change the meaning or accuracy of any canonical file (`Project_Prompt.md`, `README.md`, `FILE_INDEX.md`, `STATUS.md`), **proactively offer to update the relevant file**.
- Prefer **updating the source document** over repeating or paraphrasing instructions in chat.
- When changes are operational or machine-specific, propose updates to **`STATUS.md`**.
- When changes are structural or conceptual, propose updates to **`Project_Prompt.md`** or **`FILE_INDEX.md`**.
- When changes affect usage or helper scripts, propose updates to **`README.md`**.

The goal is to keep the repository as the **living source of truth**, minimizing stale guidance across sessions.


## 9. Lessons Learned / FAQ
- Always use Gradle wrapper.
- CLI builds must succeed before proceeding.
- Treat signing keys as production secrets.
- Document failures immediately.



