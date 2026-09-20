#!/usr/bin/env bash

# Pick a claude pane with fzf and jump to it. Tab toggles between panes of
# the launching session (default) and all sessions. Ctrl-x kills the
# selected pane.
# Usage: claude-picker.sh [--all|--current] [--client <name>]
#   --all              start in all-sessions scope (default: current)
#   --client <name>    the client to switch; the keybindings pass
#                      #{client_name}, which beats asking tmux which client is
#                      "current" when two of them share a session
#
# Browsing leaves no trace: @picker_busy freezes the history hooks (see
# tmux.conf) and every session, window and pane the preview walked through is
# put back the way it was, so last-window, last-pane and the client's last
# session all point where they did before. The one thing replaying can't undo
# is an entry that wasn't there before — selecting is the only way to touch
# those stacks, and it can only push.

# Re-exec under `mise exec` so jq/fzf resolve to real binaries: tmux run-shell
# finds them as mise shims, which re-resolve the whole toolset on every call.
if [[ -z "${__MISE_EXEC:-}" ]] && command -v mise >/dev/null 2>&1; then
  __MISE_EXEC=1 exec mise exec -- "${BASH_SOURCE[0]}" "$@"
fi

# Associative arrays and mapfile are bash 4; macOS ships 3.2, so say so rather
# than failing halfway through a switch with @picker_busy left set.
((BASH_VERSINFO[0] >= 4)) || {
  tmux display-message "claude-picker: needs bash 4+, found $BASH_VERSION"
  exit 1
}

max_height=15
max_title=40
# read treats a tab as IFS whitespace and would swallow empty fields, so the
# formats below separate theirs with US.
us=$'\x1f'

source "$(dirname "${BASH_SOURCE[0]}")/claude-pattern.sh"

scope=current
client=''
while (($#)); do
  case "$1" in
  --all) scope=all ;;
  --current) scope=current ;;
  --client)
    client=$2
    shift
    ;;
  esac
  shift
done

# orig: launching pane, restored on cancel after live-preview switching. Ids
# rather than names: session names can hold spaces, and tmux resolves a name
# by prefix, so a session dying mid-pick could hand us its namesake.
state_fmt="#{pane_id}${us}#{session_id}${us}#{client_name}${us}#{client_last_session}"
state=''
# Asked about the client that launched us, so client_last_session is that
# client's; falling back to whichever client tmux considers current.
[[ -n "$client" ]] && state=$(tmux display-message -c "$client" -p "$state_fmt" 2>/dev/null)
[[ -n "$state" ]] || state=$(tmux display-message -p "$state_fmt")
IFS=$us read -r orig orig_session fallback_client last_session <<<"$state"
[[ -n "$orig" ]] || exit 0
[[ -n "$client" ]] || client=$fallback_client

# Every switch names the client that launched us: with two clients attached,
# tmux would otherwise pick whichever it considers current.
switch=(switch-client)
[[ -n "$client" ]] && switch+=(-c "$client")

# client_last_session is a name, and only ids survive a rename.
last_session_id=''
[[ -n "$last_session" ]] && last_session_id=$(
  tmux list-sessions -F "#{session_id}${us}#{session_name}" |
    awk -F"$us" -v n="$last_session" '$2 == n { print $1; exit }'
)

visits=$(mktemp)
# The focus binding runs under sh, so both go in pre-quoted.
switch_q=$(printf '%q ' "${switch[@]}")
visits_q=$(printf '%q' "$visits")
# Hooks fire after the command list that triggered them, so the flag has to be
# set in its own call to cover the very first switch.
tmux set -g @picker_busy 1
cleanup() { # runs once, however we leave
  [[ -n "${cleaned:-}" ]] && return
  cleaned=1
  [[ -z "${landed:-}" ]] && restore
  tmux set -g @picker_busy 0
  rm -f "$visits"
}
trap cleanup EXIT
trap 'cleanup; exit 130' INT TERM HUP

# Where everything stood before the first preview. The stacks are rebuilt by
# re-selecting their entries oldest first, since selecting moves an entry back
# to the top.
declare -A win_stack   # session id -> window ids, oldest first
declare -A win_current # session id -> active window id
declare -A pane_current pane_last pane_window pane_session
snapshot() {
  local sid wid pid stack wactive pactive plast
  while IFS=$us read -r sid wid pid stack wactive pactive plast; do
    pane_session[$pid]=$sid
    pane_window[$pid]=$wid
    ((pactive)) && pane_current[$wid]=$pid
    ((plast)) && pane_last[$wid]=$pid
    ((wactive)) && win_current[$sid]=$wid
    # One row per pane, so record each window's stack slot once.
    ((stack > 0)) && [[ " ${win_stack[$sid]:-} " != *" $stack:$wid "* ]] &&
      win_stack[$sid]="${win_stack[$sid]:-} $stack:$wid"
  done < <(
    tmux list-panes -a -F "#{session_id}${us}#{window_id}${us}#{pane_id}${us}#{window_stack_index}${us}#{window_active}${us}#{pane_active}${us}#{pane_last}"
  )
  local sid_key
  for sid_key in "${!win_stack[@]}"; do
    win_stack[$sid_key]=$(tr ' ' '\n' <<<"${win_stack[$sid_key]}" |
      grep . | sort -t: -k1,1nr | cut -d: -f2 | tr '\n' ' ')
  done
}
snapshot

# Claude Code (>= 2.1.x) publishes each session's state in
# ~/.claude/sessions/<pid>.json: status busy|waiting|idle plus a "tmux"
# field "session:@win.%pane". Under tmux its terminal title glyph is
# static (always ✳), so the title carries no state anymore.
declare -A presence
load_presence() {
  local files tmux_loc pid status
  shopt -s nullglob
  files=(~/.claude/sessions/*.json)
  shopt -u nullglob
  ((${#files[@]})) || return
  while IFS=$'\t' read -r tmux_loc pid status; do
    kill -0 "$pid" 2>/dev/null || continue # stale file from a dead session
    presence["${tmux_loc##*.}"]=$status
  done < <(
    jq -r 'select(.tmux != null) | [.tmux, .pid, .status // "idle"] | @tsv' "${files[@]}" 2>/dev/null
  )
}

list_panes() { # $1: current|all
  local flags=(-a)
  [[ "$1" == current ]] && flags=(-s -t "$orig_session")
  load_presence
  tmux list-panes "${flags[@]}" -F "#{pane_current_command}${us}#{pane_id}${us}#{session_name}${us}#{window_index}:#{pane_index}${us}#{window_activity}${us}#{pane_title}" |
    while IFS=$us read -r cmd id sess loc activity title; do
      [[ "$cmd" =~ $pattern ]] || continue
      case "${presence[$id]:-}" in
      busy) rank=2 color=$'\033[33m' state=working ;;
      waiting) rank=0 color=$'\033[31m' state=blocked ;;
      idle) rank=1 color=$'\033[34m' state=done ;;
      *) rank=3 color=$'\033[32m' state=idle ;; # no presence file yet
      esac
      # Drop the leading status glyph claude still prefixes to the title.
      [[ "$title" =~ ^[✳◐◑·⠀-⣿]\ ? ]] && title=${title:${#BASH_REMATCH[0]}}
      ((${#title} > max_title)) && title="${title:0:max_title-1}…"
      printf '%s\t%s\t%s\t%s%-7s\033[0m %s \033[2m%s\033[0m  \033[2;3m%s\033[0m\n' \
        "$rank" "$activity" "$id" "$color" "$state" "$sess" "$loc" "$title"
    done |
    # needs-you first (blocked > done > working > idle), then most recent
    sort -t$'\t' -k1,1n -k2,2rn | cut -f3-
}

# Undo the preview: one tmux command list, so the server redraws once at the
# end and the panes it walks through never reach the screen. A failing command
# aborts the rest of the list, hence the liveness filter.
restore_cmds() {
  local pid wid sid seen_win='' seen_sess='' w
  alive_panes=$'\n'$(tmux list-panes -a -F '#{pane_id}')$'\n'
  alive_windows=$'\n'$(tmux list-windows -a -F '#{window_id}')$'\n'
  restore=()
  for pid in $(sort -u "$visits" 2>/dev/null) "$orig"; do
    wid=${pane_window[$pid]:-}
    sid=${pane_session[$pid]:-}
    if [[ -n "$wid" && " $seen_win " != *" $wid "* &&
      "$alive_windows" == *$'\n'"$wid"$'\n'* ]]; then
      seen_win+=" $wid"
      # last pane first, so the active one lands back on top of the stack
      for w in "${pane_last[$wid]:-}" "${pane_current[$wid]:-}"; do
        [[ -n "$w" && "$alive_panes" == *$'\n'"$w"$'\n'* ]] &&
          restore+=(select-pane -t "$w" ';')
      done
    fi
    if [[ -n "$sid" && " $seen_sess " != *" $sid "* ]]; then
      seen_sess+=" $sid"
      for w in ${win_stack[$sid]:-} "${win_current[$sid]:-}"; do
        [[ -n "$w" && "$alive_windows" == *$'\n'"$w"$'\n'* ]] &&
          restore+=(select-window -t "$sid:$w" ';')
      done
    fi
  done
}

alive() { [[ "$alive_panes" == *$'\n'"$1"$'\n'* ]]; }

# Put the preview back and return to the launching pane — or, if that pane is
# gone, at least to the session it was in.
restore() {
  local tail=()
  restore_cmds
  [[ -n "$last_session_id" ]] && tmux has-session -t "$last_session_id" 2>/dev/null &&
    tail+=("${switch[@]}" -t "$last_session_id" ';')
  if alive "$orig"; then
    tail+=("${switch[@]}" -t "$orig")
  elif tmux has-session -t "$orig_session" 2>/dev/null; then
    tail+=("${switch[@]}" -t "$orig_session")
  else # nothing to switch back to: drop restore's trailing ';'
    restore=("${restore[@]:0:${#restore[@]} - 1}")
  fi
  ((${#restore[@]} + ${#tail[@]})) && tmux "${restore[@]}" "${tail[@]}" 2>/dev/null
}

# Land on $1 (a pane) with the history written as if you had jumped straight
# there: the hooks that normally keep it are still frozen.
finish() {
  local target=$1 target_session desired_last
  restore_cmds
  alive "$target" || exit 0 # killed while we were looking at the list
  target_session=${pane_session[$target]:-}
  # Staying in the launching session leaves the client's last session alone.
  desired_last=$orig_session
  [[ "$target_session" == "$orig_session" ]] && desired_last=$last_session_id
  if [[ -n "$desired_last" && "$desired_last" != "$target_session" ]] &&
    tmux has-session -t "$desired_last" 2>/dev/null; then
    restore+=("${switch[@]}" -t "$desired_last" ';')
  fi
  restore+=("${switch[@]}" -t "$target" ';'
    set -gF @mru_seq "#{e|+|:#{@mru_seq},1}" ';'
    setw -Ft "$target" @mru "#{@mru_seq}")
  # Picking the pane you came from is a no-op the focus hook would have
  # skipped; writing it would leave last-pane pointing at the current pane.
  [[ "$target" != "$orig" ]] && alive "$orig" &&
    restore+=(';' set -g @last-pane "$orig" ';' set -g @current-pane "$target")
  tmux "${restore[@]}" && landed=1
  exit 0
}

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
      --bind "focus:execute-silent(tmux $switch_q-t {1}; printf '%s\n' {1} >>$visits_q)"
  )

  if [[ "${out[0]:-}" == tab ]]; then
    [[ "$scope" == current ]] && scope=all || scope=current
    entries=$(list_panes "$scope")
    continue
  fi

  if [[ "${out[0]:-}" == ctrl-x ]]; then
    [[ -n "${out[1]:-}" ]] && tmux kill-pane -t "${out[1]}"
    entries=$(list_panes "$scope")
    [[ -n "$entries" ]] || exit 0
    continue
  fi

  [[ -n "${out[1]:-}" ]] || exit 0 # cancelled: the exit trap puts it back
  finish "${out[1]}"
done
