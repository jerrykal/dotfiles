#!/usr/bin/env bash

# Toggle between a claude pane in the current window and the previously
# active pane; split a new claude pane on the right if none exists.
# Extra KEY=VAL args become environment for the new pane (used by
# claudecode.nvim to pass CLAUDE_CODE_SSE_PORT so claude auto-connects).
path="$1"
shift
envflags=()
for kv in "$@"; do
  envflags+=(-e "$kv")
done

source "$(dirname "${BASH_SOURCE[0]}")/claude-pattern.sh"

if [[ "$(tmux display-message -p '#{pane_current_command}')" =~ $pattern ]]; then
  tmux last-pane
  exit 0
fi

match=$(tmux list-panes -F '#{pane_current_command} #{pane_id}' |
  awk -v pat="$pattern" '$1 ~ pat { print $2; exit }')

if [[ -n "$match" ]]; then
  tmux select-pane -t "$match"
else
  # No env passed (i.e. not launched from nvim): look for a live nvim IDE
  # lockfile (~/.claude/ide/<port>.lock) whose workspace contains $path and
  # forward its port so claude auto-connects to that nvim. Longest workspace
  # match wins; dead-pid lockfiles are skipped.
  if [[ ${#envflags[@]} -eq 0 ]] && command -v jq >/dev/null; then
    best_port='' best_len=-1
    for lock in "$HOME"/.claude/ide/*.lock; do
      [[ -e "$lock" ]] || continue
      pid=$(jq -r '.pid // empty' "$lock" 2>/dev/null)
      [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null || continue
      while IFS= read -r folder; do
        [[ -n "$folder" ]] || continue
        if [[ "$path" == "$folder" || "$path" == "$folder"/* ]] && ((${#folder} > best_len)); then
          best_len=${#folder}
          best_port=$(basename "$lock" .lock)
        fi
      done < <(jq -r '.workspaceFolders[]?' "$lock" 2>/dev/null)
    done
    if [[ -n "$best_port" ]]; then
      envflags=(-e ENABLE_IDE_INTEGRATION=true -e "CLAUDE_CODE_SSE_PORT=$best_port")
    fi
  fi
  # Launch via a login fish so mise-managed runtimes are on claude's PATH.
  tmux split-window -h -l 30% -c "$path" "${envflags[@]}" "fish -lc 'exec claude'"
fi
