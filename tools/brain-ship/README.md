# brain-ship

Brainstorm-first CLI helpers that create inbox idea folders and promote them to projects.

## Files
- brain-ship.zsh

## Setup
- Source in shell: `source /Users/luke/Projects/codegen-tools/tools/brain-ship/brain-ship.zsh`
- Optional overrides: `PROJECTS_DIR`, `BRAIN_INBOX_DIR`, `BRAIN_PROMPT`, `BRAIN_STARTER_PROMPT`, `SHIP_OPEN` (set to `0` to disable auto-open), `AGENT_SCRIPTS_DIR`, `SHIP_BOOTSTRAP` (set to `0` to disable), `SHIP_BOOTSTRAP_DOCS` (set to `0` to skip docs scaffold)

## Usage
- `brain codex|claude|gemini [--dangerous] [extra args]`
- `ship "Project Name"` or `ship` (reads `- Project name: ...` from NOTES.md)

## Ship bootstrap
- Adds `AGENTS.MD` pointer to your shared guardrails.
- Copies `scripts/committer` and `scripts/docs-list.ts` from `AGENT_SCRIPTS_DIR`.
- Optional `docs/onboarding.md` scaffold (controlled by `SHIP_BOOTSTRAP_DOCS`).
