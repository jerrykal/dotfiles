#!/usr/bin/env bash

# Pick a claude pane with fzf and jump to it. Tab toggles between panes of
# the launching session (default) and all sessions. Ctrl-x kills the
# selected pane.
# Usage: claude-picker.sh [--all]  (start in all-sessions scope; default current)

max_height=15

source "$(dirname "${BASH_SOURCE[0]}")/claude-pattern.sh"

# orig: launching pane, restored on cancel after live-preview switching.
IFS=' ' read -r orig session \
  < <(tmux display-message -p '#{pane_id} #{session_name}')

# Claude writes a status glyph as the first char of the terminal title:
# braille spinner = working, dot = blocked on input, ✳ = done.
list_panes() { # $1: current|all
  local flags=(-a)
  [[ "$1" == current ]] && flags=(-s -t "=$session")
  tmux list-panes "${flags[@]}" -F '#{pane_current_command}	#{pane_id}	#{=1:pane_title}	#{session_name}	#{window_index}:#{pane_index}	#{window_activity}' |
    while IFS=$'\t' read -r cmd id glyph session loc activity; do
      [[ "$cmd" =~ $pattern ]] || continue
      case "$glyph" in
      [⠀-⣿]) rank=2 color=$'\033[33m' state=working ;;
      ·) rank=0 color=$'\033[31m' state=blocked ;;
      ✳) rank=1 color=$'\033[34m' state=done ;;
      *) rank=3 color=$'\033[32m' state=idle ;;
      esac
      printf '%s\t%s\t%s\t%s%-7s\033[0m %s \033[2m%s\033[0m\n' \
        "$rank" "$activity" "$id" "$color" "$state" "$session" "$loc"
    done |
    # needs-you first (blocked > done > working > idle), then most recent
    sort -t$'\t' -k1,1n -k2,2rn | cut -f3-
}

scope=current
[[ "${1:-}" == --all ]] && scope=all

# Empty current scope falls back to all; no claude panes anywhere: do nothing.
entries=$(list_panes "$scope")
if [[ "$scope" == current && -z "$entries" ]]; then
  scope=all
  entries=$(list_panes all)
fi
[[ -n "$entries" ]] || exit 0

# Tab exits fzf (--expect) so each scope relaunches with a popup sized to
# its own list — a running fzf --tmux popup can't be resized.
while :; do
  height=$(($(wc -l <<<"$entries") + 4))
  ((height > max_height)) && height=$max_height
  width=$(sed $'s/\033\[[0-9;]*m//g' <<<"$entries" |
    awk -F'\t' '{ if (length($2) > w) w = length($2) } END { print w + 8 }')
  ((width < 30)) && width=30

  mapfile -t out < <(
    fzf --tmux="$width,$height" <<<"$entries" \
      --no-sort --ansi --border-label " Claude panes ($scope) " --prompt '> ' \
      --delimiter '\t' --with-nth 2.. --accept-nth 1 \
      --expect=tab,ctrl-x \
      --bind 'focus:execute-silent(tmux switch-client -t {1})'
  )

  if [[ "${out[0]:-}" == tab ]]; then
    [[ "$scope" == current ]] && scope=all || scope=current
    entries=$(list_panes "$scope")
    continue
  fi

  if [[ "${out[0]:-}" == ctrl-x ]]; then
    [[ -n "${out[1]:-}" ]] && tmux kill-pane -t "${out[1]}"
    entries=$(list_panes "$scope")
    if [[ -z "$entries" ]]; then
      tmux switch-client -t "$orig" 2>/dev/null
      exit 0
    fi
    continue
  fi

  target=${out[1]:-}
  if [[ -z "$target" ]]; then
    tmux switch-client -t "$orig"
    exit 0
  fi
  tmux switch-client -t "$target"
  exit 0
done
