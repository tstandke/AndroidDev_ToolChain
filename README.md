# AndroidDev ToolChain

This repository is the authoritative reference for documenting and reproducing an Android application development toolchain (Windows-first).

## How to use this repository with an AI assistant (LLM)

This repo is structured so a single “entry-point” document can be provided to an AI assistant to establish full context and reduce repeated explanations.

1. Use **Project_Prompt.md** as the authoritative specification for what this repository is, what decisions are pinned, and what steps are required.
2. When you start a new AI session or thread, provide the AI assistant **this explicit link** and instruct it to treat the document as the source of truth:

   https://github.com/tstandke/AndroidDev_ToolChain/blob/main/Project_Prompt.md

3. Then ask your question or request the next toolchain step. The AI should follow the prompt’s pinned decisions and add new lessons learned as issues are discovered and resolved.

### Why this matters
AI assistants cannot reliably “discover” repository contents without explicit links. By using a single entry-point document that links to other repo files, you enable a controlled “cascade” of context from one URL.

## Files
- `Project_Prompt.md` — Authoritative reproduction guide and decision record
- `FILE_INDEX.md` — Index of repository contents (maintain as the repo grows)
- `README.md` — Orientation and usage instructions (this file)
- `STATUS.md` — Identifies the completed, current and next activities
