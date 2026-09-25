#!/usr/bin/env bash

# Toggle between a claude pane in the current window and the previously
# active pane; split a new claude pane on the right if none exists.
# In a window holding only claude panes: create a second claude pane
# (evenly sized, max 2 per window); with two present, toggle between them.
path="$1"

source "$(dirname "${BASH_SOURCE[0]}")/claude-pattern.sh"

# Print the port of the claudecode.nvim IDE server running in the current
# pane, if any. Its lockfile's pid is `nvim --embed`, a descendant of the
# pane's shell, so walk each lockfile pid's ancestors looking for pane_pid.
nvim_ide_port() {
  local pane_pid lock pid
  [[ "$(tmux display-message -p '#{pane_current_command}')" == nvim ]] || return
  pane_pid=$(tmux display-message -p '#{pane_pid}')
  for lock in "${CLAUDE_CONFIG_DIR:-$HOME/.claude}"/ide/*.lock; do
    [[ -e "$lock" ]] || continue
    pid=$(grep -oE '"pid": *[0-9]+' "$lock")
    pid=${pid##*[: ]}
    while ((pid > 1)); do
      if ((pid == pane_pid)); then
        basename "$lock" .lock
        return
      fi
      pid=$(ps -o ppid= -p "$pid")
    done
  done
}

launch_claude() { # $1 = width of the new pane
  # Same env claudecode.nvim sets when it launches claude itself: connects
  # to that IDE server at startup, as if picked via /ide.
  local env=() port
  port=$(nvim_ide_port)
  [[ -n "$port" ]] && env=(-e CLAUDE_CODE_SSE_PORT="$port" -e ENABLE_IDE_INTEGRATION=true)
  # Launch via a login fish so mise-managed runtimes are on claude's PATH.
  tmux split-window -h -l "$1" -c "$path" "${env[@]}" "fish -lc 'exec claude'"
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
