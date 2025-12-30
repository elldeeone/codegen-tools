# codegen-tools

Small local tools and scripts for codegen, automation, and workflow helpers.

## Layout
- tools/<tool-name> for tool-specific files and README

## Tool index
- tools/codex-telegram-notify: Codex CLI notify hook that sends Telegram pings on turn completion
- tools/brain-ship: Brainstorm-first helpers to create idea folders and ship projects

## Conventions
- keep secrets out of git; use .env.example files
- prefer small, self-contained scripts with minimal dependencies
