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

# Disambiguate otherwise-identical notifications. Ghostty (and most emulators)
# suppress a notification whose title+body exactly matches the previous one, so
# two tasks finishing in the same window back-to-back would silently drop the
# second "Task complete". A second-resolution timestamp keeps each one distinct
# and doubles as a "when did it finish" readout.
BODY="$BODY · $(date +%H:%M:%S)"

if [ -z "$TMUX" ]; then
  emit
  exit 0
fi

# Ring a bell inside the pane so tmux raises a bell alert on its window
# (monitor-bell flag / bell-style). Writing to the hook's stdout wouldn't do —
# hook output is captured by Claude Code, not the pane — so write straight to
# the pane's pty, where tmux sees the BEL and flags the window.
pane_tty=$(tmux display-message -pt "$TMUX_PANE" '#{pane_tty}' 2>/dev/null)
[ -n "$pane_tty" ] && printf '\a' >"$pane_tty" 2>/dev/null

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
