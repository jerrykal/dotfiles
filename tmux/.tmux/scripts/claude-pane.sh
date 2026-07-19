#!/usr/bin/env bash

# Toggle between a claude pane in the current window and the previously
# active pane; split a new claude pane on the right if none exists.
# In a window holding only claude panes: create a second claude pane
# (evenly sized, max 2 per window); with two present, toggle between them.
# Extra KEY=VAL args become environment for the new pane (used by
# claudecode.nvim to pass CLAUDE_CODE_SSE_PORT so claude auto-connects).
path="$1"
shift
envflags=()
for kv in "$@"; do
  envflags+=(-e "$kv")
done

source "$(dirname "${BASH_SOURCE[0]}")/claude-pattern.sh"

launch_claude() { # $1 = width of the new pane
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
  tmux split-window -h -l "$1" -c "$path" "${envflags[@]}" "fish -lc 'exec claude'"
}

current=$(tmux display-message -p '#{pane_id}')
total=0 claude_count=0 other_claude=''
while read -r cmd id; do
  ((total++))
  if [[ "$cmd" =~ $pattern ]]; then
    ((claude_count++))
    [[ "$id" != "$current" && -z "$other_claude" ]] && other_claude="$id"
  fi
done < <(tmux list-panes -F '#{pane_current_command} #{pane_id}')

if ((claude_count == total)); then
  # Window is all claude: grow to two evenly-sized panes, then toggle.
  if ((claude_count < 2)); then
    launch_claude 50%
  else
    tmux select-pane -t "$other_claude"
  fi
  exit 0
fi

if [[ "$(tmux display-message -p '#{pane_current_command}')" =~ $pattern ]]; then
  tmux last-pane
elif [[ -n "$other_claude" ]]; then
  tmux select-pane -t "$other_claude"
else
  launch_claude 30%
fi
