# codex-telegram-notify

Sends a Telegram message whenever Codex emits an agent-turn-complete event.

## Files
- notify-telegram.py
- .env.example

## Setup
1) Create a bot with @BotFather and get the bot token.
2) Message the bot once, then find your chat_id using:
   curl -s "https://api.telegram.org/bot<YOUR_TOKEN>/getUpdates"
3) Export environment variables (or load from your shell config):
   export TELEGRAM_BOT_TOKEN="..."
   export TELEGRAM_CHAT_ID="..."
4) Add the notify hook to ~/.codex/config.toml (adjust the path):
   notify = ["python3", "/Users/luke/Projects/codegen-tools/tools/codex-telegram-notify/notify-telegram.py"]

## Test
- Start Codex and wait for a turn to complete, or run:
  python3 notify-telegram.py '{"type":"agent-turn-complete","cwd":"/tmp","last-assistant-message":"Test"}'
