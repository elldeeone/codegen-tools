# Brainstorm + ship helpers
export PROJECTS_DIR="${PROJECTS_DIR:-$HOME/Projects}"
export BRAIN_INBOX_DIR="${BRAIN_INBOX_DIR:-$PROJECTS_DIR/_inbox}"
export BRAIN_PROMPT=${BRAIN_PROMPT:-$'You are in brainstorm mode.\nDuring brainstorm mode, you may do as much research online as you want, from anywhere, and take as long as you need.\nDo not run commands or edit files except the NOTES.md for the current idea folder (path provided below).\nOnly update NOTES.md when a decision, constraint, or clear next step is agreed.\nIf you are unsure whether something is decided, ask: "Should I record that?"\nWhen updating, keep it terse (Decisions / Constraints / Next steps). No fluff.\nAfter the user confirms a decision (name, stack, scope, style, interaction, etc.), immediately update NOTES.md before asking any new question or offering more options. Do not ask permission to record and do not mention the update unless the user asks.\nWhen recording the project name, use exactly: "- Project name: <name>" under Decisions.\nYour first response must greet the user by name ("Luke") and ask exactly: "What are we building today?" Do not ask any other questions or suggest ideas before the user answers.\nAfter the user shares the idea, ask if they already have a project name; if they do not, suggest 3-5 name ideas.\nThen ask clarifying questions and propose options.\nWhen the user says "ship", do a final sweep to ensure NOTES.md captures all agreed decisions, constraints, and next steps from the conversation; add anything missing, then reply with exactly one line: Exit and run: ship "<project name>". Do not add any other text.\nWait for the user to say "ship" before doing anything else.'}
export BRAIN_STARTER_PROMPT="${BRAIN_STARTER_PROMPT:-Start.}"
export SHIP_OPEN="${SHIP_OPEN:-1}"

brain() {
  local agent=""
  local danger=0

  if [[ $# -gt 0 ]]; then
    case "$1" in
      codex|claude|gemini) agent="$1"; shift ;;
    esac
  fi

  local args=()
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --dangerous|--unsafe|--yolo) danger=1 ;;
      *) args+=("$1") ;;
    esac
    shift
  done

  local dir="$BRAIN_INBOX_DIR/idea-$(date +%Y%m%d-%H%M)"
  mkdir -p "$dir" || return
  cd "$dir" || return
  [[ -f NOTES.md ]] || printf "# Brainstorm\n\n" > NOTES.md
  local notes_path="$dir/NOTES.md"
  local prompt="${BRAIN_PROMPT}"$'\n'"Current idea folder: $dir"$'\n'"NOTES.md path: $notes_path"
  local starter="$BRAIN_STARTER_PROMPT"
  local codex_full_access=(--sandbox danger-full-access --ask-for-approval never)

  case "$agent" in
    codex)
      command codex -C "$BRAIN_INBOX_DIR" "${codex_full_access[@]}" "${args[@]}" "$prompt"
      ;;
    claude)
      if (( danger )); then
        if [[ -n "$starter" ]]; then
          command claude --dangerously-skip-permissions --append-system-prompt "$prompt" "${args[@]}" "$starter"
        else
          command claude --dangerously-skip-permissions --append-system-prompt "$prompt" "${args[@]}"
        fi
      else
        if [[ -n "$starter" ]]; then
          command claude --append-system-prompt "$prompt" "${args[@]}" "$starter"
        else
          command claude --append-system-prompt "$prompt" "${args[@]}"
        fi
      fi
      ;;
    gemini)
      if (( danger )); then
        command gemini --yolo -p "$prompt" "${args[@]}"
      else
        command gemini -p "$prompt" "${args[@]}"
      fi
      ;;
    "")
      ;;
    *)
      echo "Unknown agent: $agent"
      return 1
      ;;
  esac
}

ship() {
  local src="$PWD"
  if [[ -n "$BRAIN_INBOX_DIR" && "$src" == "$BRAIN_INBOX_DIR"/* ]]; then
    local rel="${src#"$BRAIN_INBOX_DIR"/}"
    local root="${rel%%/*}"
    if [[ -n "$root" ]]; then
      src="$BRAIN_INBOX_DIR/$root"
    fi
  fi

  local name="$*"
  if [[ -z "$name" ]]; then
    local notes_file="$src/NOTES.md"
    if [[ -f "$notes_file" ]]; then
      if command -v rg >/dev/null 2>&1; then
        name=$(rg -m1 -n '^-\s*Project name:\s*' "$notes_file" | sed -E 's/^-+[[:space:]]*Project name:[[:space:]]*//')
      else
        name=$(sed -nE 's/^-+[[:space:]]*Project name:[[:space:]]*//p' "$notes_file" | head -n 1)
      fi
      name=$(printf "%s" "$name" | sed -E 's/[[:space:]]+$//')
    fi
  fi
  if [[ -z "$name" ]]; then
    echo "Usage: ship <name> (or add '- Project name: ...' to NOTES.md)"
    return 1
  fi

  local slug
  slug=$(printf "%s" "$name" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd 'a-z0-9-')
  if [[ -z "$slug" ]]; then
    echo "Could not derive a project slug from the name."
    return 1
  fi

  local dest="$PROJECTS_DIR/$slug"
  if [[ -e "$dest" ]]; then
    echo "Destination exists: $dest"
    return 1
  fi

  mkdir -p "$PROJECTS_DIR" || return
  mv "$src" "$dest" || return
  cd "$dest" || return
  [[ -d .git ]] || git init -q
  [[ -f README.md ]] || printf "# %s\n\n" "$name" > README.md

  if [[ "$SHIP_OPEN" == "1" ]]; then
    if command -v zed >/dev/null 2>&1; then
      zed .
    elif open -Ra "Zed" >/dev/null 2>&1; then
      open -a "Zed" .
    else
      echo "Zed not found; set SHIP_OPEN=0 to disable auto-open."
    fi
  fi
}
