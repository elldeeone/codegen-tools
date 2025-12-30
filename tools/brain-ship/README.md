# brain-ship

Brainstorm-first CLI helpers that create inbox idea folders and promote them to projects.

## Files
- brain-ship.zsh

## Setup
- Source in shell: `source /Users/luke/Projects/codegen-tools/tools/brain-ship/brain-ship.zsh`
- Optional overrides: `PROJECTS_DIR`, `BRAIN_INBOX_DIR`, `BRAIN_PROMPT`, `BRAIN_STARTER_PROMPT`, `SHIP_OPEN` (set to `0` to disable auto-open)

## Usage
- `brain codex|claude|gemini [--dangerous] [extra args]`
- `ship "Project Name"` or `ship` (reads `- Project name: ...` from NOTES.md)
