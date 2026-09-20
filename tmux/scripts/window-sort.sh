#!/usr/bin/env bash
#
# Move windows and panes into the session their working directory belongs to.
#
# Usage: window-sort.sh [--session|--all] [-n] [-d] [pane-id]
#
#   (default)   sort the current window: if every pane belongs to the same
#               session the whole window moves, otherwise only the panes that
#               belong elsewhere break out.
#   --session   gather everything in the current session that shares the
#               current pane's directory into that directory's session.
#   --all       sort every window of the current session.
#   -n          print the planned moves instead of running them.
#   -d          don't follow the move (stay where you are).
#
# A pane belongs to the session of its project: the nearest parent holding a
# .git, or its working directory outside a repo. The session is the one whose
# session_path is that project, else a new one named after it (the naming
# session-picker.sh uses, suffixed when the name is taken).
set -euo pipefail

mode=window follow=1 dry=0 pane=''
while (($#)); do
  case "$1" in
  --session) mode=session ;;
  --all) mode=all ;;
  -n) dry=1 ;;
  -d) follow=0 ;;
  *) pane=$1 ;;
  esac
  shift
done

[[ -n "$pane" ]] || pane=$(tmux display-message -p '#{pane_id}')

note() { tmux display-message "$*"; }
die() {
  note "$*"
  exit 0
}

# Physical path, or the input unchanged when it no longer exists.
canon() { (cd "$1" 2>/dev/null && pwd -P) || printf '%s\n' "$1"; }

# Nearest parent holding a .git, else the directory itself.
project_of() {
  local dir
  dir=$(canon "$1")
  local probe=$dir
  while [[ -n "$probe" ]]; do
    [[ -e "$probe/.git" ]] && {
      printf '%s\n' "$probe"
      return
    }
    probe=${probe%/*}
  done
  printf '%s\n' "$dir"
}

# tmux forbids '.' and ':' in session names; a leading '.' is dropped so
# dotdirs get a bare name (same rules as session-picker.sh).
session_name_for() {
  local name
  name=$(basename "$1")
  printf '%s\n' "${name#.}" | tr '.:' '__'
}

# Session whose working directory is $1, or '' if there is none.
session_at() {
  local project=$1 name path
  while IFS=$'\t' read -r name path; do
    [[ "$(canon "$path")" == "$project" ]] && {
      printf '%s\n' "$name"
      return
    }
  done < <(tmux list-sessions -F '#{session_name}	#{session_path}')
  return 0
}

# Plan: one "<project>\t<session>" line per project touched, so a session is
# resolved (and created) once even when several windows feed it.
plan_sessions=''
plan_moves=''

# Session that owns $1, creating nothing yet, into $resolved. Names already
# taken by another project get a numeric suffix, counting from 2. (Result goes
# through a global because a command substitution could not grow the plan.)
resolved=''
resolve_session() {
  local project=$1 n=2
  resolved=$(printf '%s' "$plan_sessions" |
    awk -F'\t' -v p="$project" '$1 == p {print $2}')
  [[ -n "$resolved" ]] && return
  resolved=$(session_at "$project")
  if [[ -z "$resolved" ]]; then
    resolved=$(session_name_for "$project")
    while tmux has-session -t "=$resolved" 2>/dev/null || printf '%s' "$plan_sessions" |
      awk -F'\t' -v s="$resolved" '$2 == s { found = 1 } END { exit !found }'; do
      resolved="$(session_name_for "$project")_$n"
      n=$((n + 1))
    done
  fi
  plan_sessions="$plan_sessions$project	$resolved"$'\n'
}

# kind, source, destination session, window name for a broken-out pane
add_move() { plan_moves="$plan_moves$1	$2	$3	${4:-}"$'\n'; }

src_session=$(tmux display-message -pt "$pane" '#{session_name}')
src_window=$(tmux display-message -pt "$pane" '#{window_id}')
zoomed=$(tmux display-message -pt "$pane" '#{window_zoomed_flag}')

# Emit moves for one window: the whole window when every pane agrees on a
# session other than its own, else the panes that belong elsewhere.
# $2, when set, restricts the window to panes of that project.
sort_window() {
  local window=$1 only=${2:-} id path project target
  local panes='' targets='' total=0 matched=0 wname=''
  # A window the user named keeps that name when its panes break out; an
  # automatically named one is left to rename itself.
  [[ $(tmux display-message -pt "$window" '#{automatic-rename}') == 0 ]] &&
    wname=$(tmux display-message -pt "$window" '#{window_name}')
  while IFS=$'\t' read -r id path; do
    total=$((total + 1))
    project=$(project_of "$path")
    [[ -n "$only" && "$project" != "$only" ]] && continue
    resolve_session "$project"
    target=$resolved
    [[ "$target" == "$src_session" ]] && continue
    matched=$((matched + 1))
    panes="$panes$id	$target"$'\n'
    printf '%s' "$targets" | grep -qxF "$target" || targets="$targets$target"$'\n'
  done < <(tmux list-panes -t "$window" -F '#{pane_id}	#{pane_current_path}')

  ((matched)) || return 0
  if ((matched == total)) && [[ $(printf '%s' "$targets" | grep -c .) -eq 1 ]]; then
    add_move window "$window" "$(printf '%s' "$targets" | head -1)"
  else
    while IFS=$'\t' read -r id target; do
      [[ -n "$id" ]] && add_move pane "$id" "$target" "$wname"
    done < <(printf '%s' "$panes")
  fi
  return 0
}

case "$mode" in
window)
  sort_window "$src_window"
  ;;
all)
  while read -r window; do sort_window "$window"; done < <(
    tmux list-windows -t "=$src_session" -F '#{window_id}'
  )
  ;;
session)
  only=$(project_of "$(tmux display-message -pt "$pane" '#{pane_current_path}')")
  while read -r window; do sort_window "$window" "$only"; done < <(
    tmux list-windows -t "=$src_session" -F '#{window_id}'
  )
  ;;
esac

[[ -n "$plan_moves" ]] || die "window-sort: nothing to move"

if ((dry)); then
  note "window-sort:$(printf '%s' "$plan_moves" |
    awk -F'\t' '{ printf " %s %s -> %s;", $1, $2, $3 }')"
  exit 0
fi

# Sessions are created just before the first move into them, so a failed plan
# leaves no empty session behind. The window new-session opens is killed once
# a real one has arrived.
placeholders=''
ensure_session() {
  local target=$1 project placeholder
  tmux has-session -t "=$target" 2>/dev/null && return
  project=$(printf '%s' "$plan_sessions" | awk -F'\t' -v s="$target" '$2 == s {print $1}')
  placeholder=$(tmux new-session -d -s "$target" -c "$project" -PF '#{window_id}')
  placeholders="$placeholders$placeholder"$'\n'
}

while IFS=$'\t' read -r kind source target name; do
  [[ -n "$kind" ]] || continue
  ensure_session "$target"
  case "$kind" in
  window) tmux move-window -s "$source" -t "=$target:" ;;
  pane)
    args=(-d -s "$source" -t "=$target:")
    [[ -n "$name" ]] && args=(-n "$name" "${args[@]}")
    tmux break-pane "${args[@]}"
    ;;
  esac
done < <(printf '%s' "$plan_moves")

while read -r placeholder; do
  [[ -n "$placeholder" ]] && tmux kill-window -t "$placeholder"
done < <(printf '%s' "$placeholders")

if ((follow)); then
  tmux select-pane -t "$pane"
  tmux select-window -t "$pane"
  tmux switch-client -t "$pane" 2>/dev/null || true
fi

# Breaking a pane out drops the zoom flag: restore it when the pane still has
# company to be zoomed over. resize-pane -Z toggles, so skip a window that
# carried its zoom along.
if ((zoomed)) &&
  [[ $(tmux display-message -pt "$pane" '#{window_zoomed_flag}') == 0 ]] &&
  [[ $(tmux display-message -pt "$pane" '#{window_panes}') -gt 1 ]]; then
  tmux resize-pane -Zt "$pane"
fi

exit 0
