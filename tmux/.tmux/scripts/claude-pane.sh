#!/usr/bin/env bash

# Toggle between a claude pane in the current window and the previously
# active pane; split a new claude pane on the right if none exists.
path="$1"

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
  # Launch via a login fish so mise-managed runtimes are on claude's PATH.
  tmux split-window -h -l 35% -c "$path" "fish -lc 'exec claude'"
fi
