#!/bin/sh
# exp-dispatch run epilogue — called by the dispatch wrapper as:
#   sh ~/.claude/skills/exp-dispatch/finish.sh <run-id> <exit-code>
# Prints the exit banner, writes the status file, re-aggregates the window's
# status suffix (* running / ! any failure / bare name when all exit 0),
# rings the bell.
run=$1; st=$2
cache="$HOME/.cache/exp-dispatch"
printf '\n── exp-dispatch: exit %s ──\n' "$st"
echo "$st" > "$cache/$run.status"

[ -n "$TMUX_PANE" ] || exit 0
win=$(tmux display -p -t "$TMUX_PANE" '#{window_id}') || exit 0
sym=
for r in $(tmux list-panes -t "$win" -f '#{@exp-dispatch}' -F '#{@exp-dispatch}'); do
  if [ ! -f "$cache/$r.status" ]; then sym='*'; break; fi
  [ "$(cat "$cache/$r.status")" != 0 ] && sym='!'
done
base=$(tmux display -p -t "$win" '#{window_name}')
base=${base%\*}; base=${base%!}
tmux rename-window -t "$win" "$base$sym"
printf '\a'
