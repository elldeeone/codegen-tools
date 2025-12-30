# Brainstorm + ship helpers
export PROJECTS_DIR="${PROJECTS_DIR:-$HOME/Projects}"
export BRAIN_INBOX_DIR="${BRAIN_INBOX_DIR:-$PROJECTS_DIR/_inbox}"
export BRAIN_PROMPT=${BRAIN_PROMPT:-$'You are in brainstorm mode.\nDo not run commands or edit files except the NOTES.md for the current idea folder (path provided below).\nOnly update NOTES.md when a decision, constraint, or clear next step is agreed.\nIf you are unsure whether something is decided, ask: "Should I record that?"\nWhen updating, keep it terse (Decisions / Constraints / Next steps). No fluff.\nYour first response must greet the user by name ("Luke") and ask exactly: "What are we building today?" Do not ask any other questions or suggest ideas before the user answers.\nAfter the user shares the idea, ask if they already have a project name; if they do not, suggest 3-5 name ideas.\nThen ask clarifying questions and propose options.\nWait for the user to say "ship" before doing anything else.'}

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

  case "$agent" in
    codex)
      if (( danger )); then
        command codex -C "$BRAIN_INBOX_DIR" --dangerously-bypass-approvals-and-sandbox "${args[@]}" "$prompt"
      else
        command codex -C "$BRAIN_INBOX_DIR" "${args[@]}" "$prompt"
      fi
      ;;
    claude)
      if (( danger )); then
        command claude --dangerously-skip-permissions --append-system-prompt "$prompt" "${args[@]}"
      else
        command claude --append-system-prompt "$prompt" "${args[@]}"
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
  local name="$*"
  if [[ -z "$name" ]]; then
    echo "Usage: ship <name>"
    return 1
  fi

  local slug
  slug=$(printf "%s" "$name" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd 'a-z0-9-')
  if [[ -z "$slug" ]]; then
    echo "Could not derive a project slug from the name."
    return 1
  fi

  local src="$PWD"
  if [[ -n "$BRAIN_INBOX_DIR" && "$src" == "$BRAIN_INBOX_DIR"/* ]]; then
    local rel="${src#"$BRAIN_INBOX_DIR"/}"
    local root="${rel%%/*}"
    if [[ -n "$root" ]]; then
      src="$BRAIN_INBOX_DIR/$root"
    fi
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
}
