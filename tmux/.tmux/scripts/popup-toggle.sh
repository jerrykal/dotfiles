#!/usr/bin/env bash
#
# Toggleable popups backed by detached sessions on a separate tmux server
# (socket "popup"), so they never appear in the main session list.
#
# Usage: popup-toggle.sh [-s scope] [-n name] [-w width] [-h height] [-k key]
#                     [command...]
#        popup-toggle.sh --gc
#
#   -s pane|window|session|cwd|global   scope (default: session). A scoped
#      popup lives as long as its owner: when the owner pane/window/session
#      closes, the popup session is killed by --gc (wired to hooks in
#      tmux.conf). "cwd" popups are shared by all panes in the same working
#      directory and live while any pane still has that cwd. "global" popups
#      are shared everywhere and never GC'd.
#   -n name    popup name, allows several popups per scope (default: scratch)
#   -k key     also bind <key> inside the popup server to close the popup,
#              so the same key toggles both ways
#   command    run in the popup session (default: your shell)
set -euo pipefail

SOCKET=${POPUP_TOGGLE_SOCKET:-popup}
POPUP_CONF="$HOME/.config/tmux/tmux.popup.conf"

pt() { tmux -L "$SOCKET" "$@"; }

# Session names can't contain '.' or ':', so cwd owners are a hash of the path.
hash_dir() { cksum <<<"$1" | cut -d' ' -f1; }

# Popup session name wire format: <scope initial><owner>-<name>
sname_encode() { printf '%s%s-%s' "${1:0:1}" "$2" "${3//[.:]/_}"; }
sname_owner() {
  local o=${1:1}
  printf '%s' "${o%%-*}"
}

# Live owner ids per scope initial, one per line; must produce the same
# strings as the owner construction in main below. pane/window/session owners
# embed the main server's pid: a restarted server reuses pane/window/session
# ids, so popups from a dead server must never match the new owners. cwd
# owners are pid-less path hashes — a directory's identity survives restarts.
alive_ids() {
  case $1 in
  p) tmux list-panes -a -F '#{pid}_#{pane_id}' ;;
  w) tmux list-windows -a -F '#{pid}_#{window_id}' ;;
  s) tmux list-sessions -F '#{pid}_#{session_id}' ;;
  c) tmux list-panes -a -F '#{pane_current_path}' | sort -u |
    while IFS= read -r p; do hash_dir "$p"; done ;;
  esac
}

gc() {
  local sessions s prefix
  local -A alive=()
  sessions=$(pt list-sessions -F '#{session_name}' 2>/dev/null) || return 0
  while IFS= read -r s; do
    case $s in
    [pwsc][0-9]*) prefix=${s:0:1} ;;
    *) continue ;;
    esac
    [[ -v alive[$prefix] ]] || alive[$prefix]=$(alive_ids "$prefix")
    grep -qxF "$(sname_owner "$s")" <<<"${alive[$prefix]}" ||
      pt kill-session -t "=$s" 2>/dev/null || true
  done <<<"$sessions"
}

if [[ "${1:-}" == "--gc" ]]; then
  gc
  exit 0
fi

# Invoked from inside the popup server: toggling just closes the popup.
sock=${TMUX:-}
sock=${sock%%,*}
if [[ "${sock##*/}" == "$SOCKET" ]]; then
  exec tmux detach-client
fi

scope=session name=scratch width=90% height=90% key=""
while getopts :s:n:w:h:k: opt; do
  case $opt in
  s) scope=$OPTARG ;;
  n) name=$OPTARG ;;
  w) width=$OPTARG ;;
  h) height=$OPTARG ;;
  k) key=$OPTARG ;;
  *)
    echo "usage: popup-toggle.sh [-s pane|window|session|cwd|global] [-n name] [-w width] [-h height] [-k key] [command...]" >&2
    exit 1
    ;;
  esac
done
shift $((OPTIND - 1))

# One round trip for everything a scope may need; path last, it can have spaces.
IFS=' ' read -r srv sess win pane cwd \
  < <(tmux display-message -p '#{pid} #{session_id} #{window_id} #{pane_id} #{pane_current_path}')
case $scope in
pane) owner="${srv}_${pane}" ;;
window) owner="${srv}_${win}" ;;
session) owner="${srv}_${sess}" ;;
cwd) owner=$(hash_dir "$cwd") ;;
global) owner="" ;;
*)
  echo "popup-toggle.sh: bad scope '$scope' (pane|window|session|cwd|global)" >&2
  exit 1
  ;;
esac
sname=$(sname_encode "$scope" "$owner" "$name")

gc # sweep orphans on every toggle too, in case a hook was missed

# -f only takes effect when the popup server first starts; the conf sets
# exit-empty off so the server (and the binding below) outlives its sessions.
pt -f "$POPUP_CONF" start-server
if [[ -n "$key" ]]; then
  pt bind-key -n "$key" detach-client
fi

exec tmux display-popup -w "$width" -h "$height" -T " $name [$scope] " -E -- \
  tmux -L "$SOCKET" new-session -A -s "$sname" -c "$cwd" "$@"
