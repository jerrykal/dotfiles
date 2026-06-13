#!/usr/bin/env bash
# Desktop notification from Claude Code (OSC 777).
#
# Inside tmux, write the notification straight to each attached client's
# terminal (the real emulator) instead of routing it through this pane via the
# tmux passthrough sequence. Passthrough only reaches the emulator for the
# *visible* pane, so a notification fired from a Claude running in a background
# tmux window never arrives. Writing to #{client_tty} sidesteps that and works
# regardless of which window is currently active.

emit() { printf '\e]777;notify;%s;%s\a' "$TITLE" "$BODY"; }

if [ -z "$TMUX" ]; then
  emit
  exit 0
fi

# Window holding the pane that triggered this hook, plus a human-readable
# "session:index name" tag so the notification says where it came from.
my_window=$(tmux display-message -pt "$TMUX_PANE" '#{window_id}' 2>/dev/null)
loc=$(tmux display-message -pt "$TMUX_PANE" '#{session_name}:#{window_index} #{window_name}' 2>/dev/null)
[ -n "$loc" ] && TITLE="$TITLE — $loc"

# Notify every attached client, except one that is focused *and* already
# viewing Claude's window — the user is watching, so stay quiet there.
# Fields are space-free (tty, @window, 0/1), so default word-splitting is safe.
while read -r ctty cwindow cfocused; do
  [ -n "$ctty" ] || continue
  [ "$cfocused" = 1 ] && [ "$cwindow" = "$my_window" ] && continue
  emit >"$ctty" 2>/dev/null
done < <(tmux list-clients -F '#{client_tty} #{window_id} #{?#{m:*focused*,#{client_flags}},1,0}' 2>/dev/null)
