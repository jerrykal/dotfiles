#!/usr/bin/env bash

# Toggle between a claude pane in the current window and the previously
# active pane; split a new claude pane on the right if none exists.
# In a window holding only claude panes: create a second claude pane
# (evenly sized, max 2 per window); with two present, toggle between them.
path="$1"

source "$(dirname "${BASH_SOURCE[0]}")/claude-pattern.sh"

launch_claude() { # $1 = width of the new pane
  # Launch via a login fish so mise-managed runtimes are on claude's PATH.
  tmux split-window -h -l "$1" -c "$path" "fish -lc 'exec claude'"
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
