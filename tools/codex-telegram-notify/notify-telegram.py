#!/usr/bin/env python3

import json
import os
import sys
import urllib.parse
import urllib.request


def clip(text: str, limit: int = 3500) -> str:
    if len(text) <= limit:
        return text
    return text[: limit - 3] + "..."


def main() -> int:
    if len(sys.argv) != 2:
        print("Usage: notify-telegram.py <NOTIFICATION_JSON>", file=sys.stderr)
        return 1

    try:
        notification = json.loads(sys.argv[1])
    except json.JSONDecodeError:
        print("Invalid notification JSON", file=sys.stderr)
        return 1

    if notification.get("type") != "agent-turn-complete":
        return 0

    token = os.environ.get("TELEGRAM_BOT_TOKEN")
    chat_id = os.environ.get("TELEGRAM_CHAT_ID")
    if not token or not chat_id:
        print("Missing TELEGRAM_BOT_TOKEN or TELEGRAM_CHAT_ID", file=sys.stderr)
        return 1

    cwd = notification.get("cwd") or ""
    project = os.path.basename(cwd) if cwd else ""
    header = "Codex turn complete - waiting on you."
    if project:
        header = f"Codex ({project}) turn complete - waiting on you."

    last_message = notification.get("last-assistant-message") or ""
    message = header
    if last_message:
        message = f"{header}\n\n{last_message}"

    payload = urllib.parse.urlencode({"chat_id": chat_id, "text": clip(message)}).encode()
    url = f"https://api.telegram.org/bot{token}/sendMessage"
    req = urllib.request.Request(url, data=payload, method="POST")

    with urllib.request.urlopen(req, timeout=10) as resp:
        resp.read()

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
