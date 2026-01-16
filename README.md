# AndroidDev ToolChain

This repository is the **authoritative reference** for documenting, validating, and reproducing an **Android application development toolchain** (Windows-first), built around **Flutter**, **Firebase**, and **Google Cloud Platform (GCP)**.

The primary goal of this repository is to ensure that a developer (human or AI-assisted) can **reliably recreate a known-working toolchain**, detect regressions caused by toolchain updates, and validate end-to-end application execution before building production software.

---

## How to Use This Repository with an AI Assistant (LLM)

This repository is structured so a single **entry-point document** can be provided to an AI assistant to establish full context and reduce repeated explanations.

### Recommended workflow

1. Use **`Project_Prompt.md`** as the authoritative specification for:
   - What this repository represents
   - Which decisions are pinned
   - Which steps must be followed (and in what order)

2. When starting a new AI session or thread, provide the AI assistant **this explicit link** and instruct it to treat the document as the source of truth:

   https://github.com/tstandke/AndroidDev_ToolChain/blob/main/Project_Prompt.md

3. Then ask your question or request the next toolchain step.
   - The AI should follow the prompt’s pinned decisions
   - The AI should prompt for documentation updates when drift is detected

### Why this matters

AI assistants cannot reliably “discover” repository contents without explicit links.  
By using a **single authoritative entry-point document** that links to other canonical files, you enable a controlled cascade of context and prevent silent assumption drift.

---

## Canonical Reference Application (Toolchain Smoke Test)

This repository includes a **minimal Flutter reference application** located at:

- `reference_app/`

The reference application exists solely to **validate the Android / Flutter toolchain end-to-end** and to detect when **toolchain updates** (Flutter, Android SDK, Gradle, Android Studio, Firebase tooling) introduce breaking changes.

### What the reference application is

The reference application is used to validate:

- `flutter run` on an Android emulator or physical device
- Android build, install, and runtime execution
- Firebase Authentication (Google Sign-In)
- Server-side authorization enforcement (post-authentication)
- Local biometric unlock for authenticated sessions  
  (biometrics are **never** an identity authority)

The reference application is exercised as part of:

- **Section 6.4** of `Project_Prompt.md`

### What the reference application is not

- It is **not** a production application
- It is **not** a UI/UX exemplar
- It is **not** intended to accumulate business logic
- It should **not** be extended beyond what is required for toolchain validation

### How to use the reference application

To run the reference application as a toolchain smoke test:

```powershell
cd reference_app
flutter pub get
flutter run
```

If this step fails after a toolchain update, the failure should be treated as a **toolchain regression** until proven otherwise.

---

## Repository Files

- `Project_Prompt.md` — Authoritative reproduction guide and pinned decision record
- `FILE_INDEX.md` — Canonical index of repository contents and intent
- `README.md` — Orientation and usage instructions (this file)
- `STATUS.md` — Machine-specific progress, completion state, and next actions
