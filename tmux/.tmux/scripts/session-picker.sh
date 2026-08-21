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

# tmux forbids '.' and ':' in session names; a leading '.' is dropped so
# dotdirs get a bare name.
session_name_for() {
  local name
  name=$(basename "${1/#\~/$HOME}")
  printf '%s\n' "${name#.}" | tr '.:' '__'
}

# First unused "<base>_<num>" name, counting from 2.
next_free_name() {
  local base=$1 n=2
  while tmux has-session -t "=${base}_${n}" 2>/dev/null; do ((n++)); done
  printf '%s_%d\n' "$base" "$n"
}

# Input box for a session name (run-shell gives no tty, so use an empty fzf
# with --print-query as the prompt). Esc cancels; the typed name is sanitized
# like session_name_for.
prompt_session_name() {
  local query status
  query=$(fzf --tmux=50%,7 --print-query --query "$1" \
    --prompt 'session name: ' --no-info --pointer '' \
    --bind 'ctrl-u:clear-query' \
    --border-label " ${2:-New session} " </dev/null)
  status=$?
  ((status == 130)) && return 1
  printf '%s\n' "$query" | tr '.:' '__'
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
  if tmux has-session -t "=$name" 2>/dev/null; then
    # Name taken (e.g. another dir with the same basename): ask for a new one.
    name=$(prompt_session_name "$(next_free_name "$name")") || return 0
    [[ -n "$name" ]] || return 0
  fi
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
    --expect=alt-enter,ctrl-r \
    --accept-nth 2.. \
    --bind 'ctrl-x:execute-silent(bash -c '\''for target in "$@"; do tmux kill-session -t "=$target"; done'\'' _ {+2..})+reload('"$self"' --list)' \
    --preview-window 'right:55%' \
    --preview "$self --preview {2..}"
) || exit 0

key=${selection[0]:-}
target=${selection[1]:-${selection[0]:-}}

[[ -n "$target" ]] || exit 0

# ctrl-r: rename a session, or create a session under a chosen name for a dir.
if [[ "$key" == "ctrl-r" ]]; then
  if tmux has-session -t "=$target" 2>/dev/null; then
    new=$(prompt_session_name "$target" 'Rename session') || exit 0
    [[ -n "$new" && "$new" != "$target" ]] || exit 0
    if tmux has-session -t "=$new" 2>/dev/null; then
      tmux display-message "session '$new' already exists"
    else
      tmux rename-session -t "=$target" "$new"
    fi
  else
    dir=${target/#\~/$HOME}
    [[ -d "$dir" ]] || exit 0
    name=$(session_name_for "$dir")
    tmux has-session -t "=$name" 2>/dev/null && name=$(next_free_name "$name")
    name=$(prompt_session_name "$name" 'New session') || exit 0
    [[ -n "$name" ]] || exit 0
    tmux has-session -t "=$name" 2>/dev/null ||
      tmux new-session -ds "$name" -c "$dir"
    goto "$name"
  fi
  exit 0
fi

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
