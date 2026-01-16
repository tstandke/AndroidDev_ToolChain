# FILE_INDEX

This file provides a **stable, human- and AI-readable index** of all meaningful
files and directories in this repository.

Its purpose is to explain **what exists, why it exists, and how it should be used**.
It complements (but does not replace) the GitHub file tree.

---

## Root Files (Canonical Documentation Spine)

- `Project_Prompt.md`
  - **Authoritative specification**
  - Primary entry point for AI assistants
  - Defines pinned decisions, toolchain scope, and reproduction steps

- `README.md`
  - Orientation and usage guide for humans and AI
  - Explains repository workflow and helper scripts
  - Safe to edit frequently

- `FILE_INDEX.md`
  - This file
  - Canonical map of repository contents and intent
  - Update only when files/directories are added, removed, or repurposed

- `STATUS.md`
  - Machine- and time-specific progress tracker
  - Records what is completed, in progress, blocked, and next actions
  - Intended to be updated frequently

---

## Directories

- `scripts/`
  - Helper and verification scripts
  - Contains narrow “safe default” Git update helpers (`GitUpdate-*.ps1`)
  - Scripts here should be referenced from `README.md` and/or `Project_Prompt.md`

- `docs/` (planned)
  - Intended location for detailed toolchain documentation
  - Examples: Android Studio setup, SDK verification, emulator workflows
  - Files here should be linked from `Project_Prompt.md`

- `templates/` (planned)
  - Intended location for reusable templates
  - Examples: GitHub Actions workflows, project scaffolds

---

## Document Inventory (in `docs/`)

- `6_2_Flutter_Toolchain_Installation.md`
  - Step-by-step procedure for verifying, upgrading, or installing the Flutter SDK as part of Section 6.2 of the canonical toolchain setup flow.

---

## Update Rules

- Update `FILE_INDEX.md` when:
  - A new root-level file is added
  - A new directory is added
  - The role or authority of a file changes

- Do NOT update `FILE_INDEX.md` for:
  - Minor text edits
  - Routine documentation updates
  - Formatting-only changes

---

## Authoritative Hierarchy

1. `Project_Prompt.md` — intent and pinned decisions
2. `README.md` — usage and operational workflow
3. `FILE_INDEX.md` — structure and purpose
4. `STATUS.md` — completion state and next actions
