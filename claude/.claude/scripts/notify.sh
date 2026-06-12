#!/usr/bin/env bash

if [ -n "$TMUX" ]; then
  if tmux display-message -p '#{client_flags}' 2>/dev/null | grep -q 'focused' &&
    [ "$(tmux display-message -pt "$TMUX_PANE" '#{window_active}')" = "1" ]; then
    exit 0
  fi
  PANE_TTY=$(tmux display-message -p '#{pane_tty}')
  printf '\ePtmux;\e\e]777;notify;%s;%s\a\e\\' "$TITLE" "$BODY" >"$PANE_TTY"
else
  printf '\e]777;notify;%s;%s\a' "$TITLE" "$BODY"
fi
