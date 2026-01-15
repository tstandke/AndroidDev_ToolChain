# FILE_INDEX

This file provides a **stable, human- and AI-readable index** of all meaningful
files and directories in this repository.

Its purpose is to explain **what exists, why it exists, and how it should be used**.
It complements (but does not replace) the GitHub file tree.

---

## Root Files

- `Project_Prompt.md`
  - **Authoritative specification**
  - Primary entry point for AI assistants
  - Defines pinned decisions, toolchain scope, and reproduction steps
  - Must be referenced explicitly when engaging an AI on this project

- `README.md`
  - Orientation and usage guide for humans and AI
  - Explains how to interact with this repository and its helper scripts
  - Safe to edit frequently

- `FILE_INDEX.md`
  - This file
  - Canonical map of repository contents and intent
  - Updated only when files/directories are added, removed, or repurposed

- `GitUpdate-README.ps1`
  - PowerShell helper script
  - Stages, commits, and pushes changes to `README.md` only
  - Safe default automation to avoid accidental commits

- `GitUpdate-Project_Prompt.ps1`
  - PowerShell helper script
  - Stages, commits, and pushes changes to `Project_Prompt.md` only
  - Ensures the authoritative prompt is updated in a controlled manner

- `GitUpdate-FILE_INDEX.ps1`
  - PowerShell helper script
  - Stages, commits, and pushes changes to `FILE_INDEX.md` only
  - Keeps the repository map in sync with structural changes

---

## Directories (Current / Planned)

- `docs/`
  - Intended location for detailed toolchain documentation
  - Examples: Android Studio setup, SDK verification, emulator workflows
  - Files here should be linked from `Project_Prompt.md`

- `scripts/`
  - Intended location for verification or diagnostic scripts
  - Scripts here should be documented in `README.md` or `Project_Prompt.md`

- `templates/`
  - Intended location for reusable templates
  - Examples: GitHub Actions workflows, project scaffolds

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

1. `Project_Prompt.md` — defines intent and decisions
2. `README.md` — explains usage and workflow
3. `FILE_INDEX.md` — explains structure and purpose
