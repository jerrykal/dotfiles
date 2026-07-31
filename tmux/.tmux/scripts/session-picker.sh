#!/usr/bin/env bash

# Session picker: live tmux sessions + zoxide dirs, no external session manager.
# Subcommands (used internally by fzf bindings): --list, --preview <target>.
# Optional positional arg: skip the picker, connect to the first matching entry.

self=$(realpath "${BASH_SOURCE[0]}")

session_icon=$'\033[34m\033[39m'
dir_icon=$'\033[36m\033[39m'

# Sessions (most recently attached first), then zoxide dirs by frecency.
list_targets() {
  tmux list-sessions -F '#{session_last_attached} #{session_name}' 2>/dev/null |
    sort -rn | cut -d' ' -f2- |
    while IFS= read -r name; do printf '%s %s\n' "$session_icon" "$name"; done
  zoxide query -l |
    while IFS= read -r dir; do
      case "$dir" in "$HOME" | "$HOME"/*) dir="~${dir#"$HOME"}" ;; esac
      printf '%s %s\n' "$dir_icon" "$dir"
    done
}

# tmux forbids '.' and ':' in session names; a leading '.' becomes '_'
# (matches the names sesh used to create, so existing sessions still match).
session_name_for() {
  basename "${1/#\~/$HOME}" | tr '.:' '__'
}

goto() {
  if [[ -n "${TMUX:-}" ]]; then
    tmux switch-client -t "=$1"
  else
    tmux attach-session -t "=$1"
  fi
}

# Target is either a session name or a directory; create the session if needed.
connect() {
  local target=$1
  if tmux has-session -t "=$target" 2>/dev/null; then
    goto "$target"
    return
  fi
  local dir=${target/#\~/$HOME}
  [[ -d "$dir" ]] || return 0
  local name
  name=$(session_name_for "$dir")
  tmux has-session -t "=$name" 2>/dev/null ||
    tmux new-session -ds "$name" -c "$dir"
  goto "$name"
}

# Instant switch to the previous session. Native switch-client -l covers the
# common case; if that session died, fall back to the most recently attached
# other session.
last() {
  if [[ -z "${TMUX:-}" ]]; then
    tmux attach-session
    return
  fi
  tmux switch-client -l 2>/dev/null && return
  local current target
  current=$(tmux display-message -p '#S')
  target=$(
    tmux list-sessions -F '#{session_last_attached} #{session_name}' |
      sort -rn | cut -d' ' -f2- | grep -vxF "$current" | head -1
  )
  [[ -n "$target" ]] && tmux switch-client -t "=$target"
}

preview() {
  local target=$1
  if tmux has-session -t "=$target" 2>/dev/null; then
    tmux capture-pane -ep -t "=$target:"
  else
    eza --all -1 --group-directories-first --color=always "${target/#\~/$HOME}"
  fi
}

case "${1:-}" in
--list)
  list_targets
  exit 0
  ;;
--preview)
  preview "$2"
  exit 0
  ;;
--last)
  last
  exit 0
  ;;
'') ;;
*)
  # Skip the picker, connect to the first matching entry.
  target=$(list_targets | fzf --filter="$1" --no-sort --accept-nth 2.. | head -1)
  [[ -n "$target" ]] || exit 0
  connect "$target"
  exit 0
  ;;
esac

border_label=" Sessions "
[[ -z "${TMUX:-}" ]] && border_label=" Sessions (${USER}@${HOSTNAME}) "

mapfile -t selection < <(
  list_targets | fzf --tmux=80%,70% \
    --multi \
    --no-sort --ansi --border-label "$border_label" --prompt '> ' \
    --expect=alt-enter \
    --accept-nth 2.. \
    --bind 'ctrl-x:execute-silent(bash -c '\''for target in "$@"; do tmux kill-session -t "=$target"; done'\'' _ {+2..})+reload('"$self"' --list)' \
    --preview-window 'right:55%' \
    --preview "$self --preview {2..}"
) || exit 0

key=${selection[0]:-}
target=${selection[1]:-${selection[0]:-}}

[[ -n "$target" ]] || exit 0

if [[ "$key" == "alt-enter" ]] && tmux has-session -t "=$target" 2>/dev/null; then
  duplicate="$target 2"
  if tmux has-session -t "=$duplicate" 2>/dev/null; then
    tmux switch-client -t "=$duplicate"
  else
    tmux new-session -d -t "=$target" -s "$duplicate" &&
      tmux switch-client -t "=$duplicate"
  fi
else
  connect "$target"
fi
