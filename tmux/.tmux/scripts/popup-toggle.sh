#!/usr/bin/env bash
#
# Toggleable popups backed by detached sessions on a separate tmux server
# (socket "popup"), so they never appear in the main session list.
#
# Usage: popup-toggle.sh [-s scope] [-n name] [-w width] [-h height]
#                     [command...]
#        popup-toggle.sh --gc | --mirror
#
#   -s pane|window|session|server|cwd|global   scope (default: session). A
#      scoped popup lives as long as its owner: when the owner pane/window/
#      session closes, the popup session is killed by --gc (wired to hooks in
#      tmux.conf). "server" popups are shared by every session and die with
#      the server. "cwd" popups are shared by all panes in the same working
#      directory and live while any pane still has that cwd. "global" popups
#      are shared everywhere and never GC'd.
#   -n name    popup name, allows several popups per scope (default: scratch)
#   command    run in the popup session (default: your shell)
#
# Every main-server key bound to this script is mirrored into the popup
# server on each open, so inside any popup its own key closes it and any
# other popup's key swaps the current popup for that one — no key has to
# have been used before.
#
# Inside any popup, M-Enter (POPUP_TOGGLE_FS_KEY) toggles the popup between
# its default size and full screen. The state sticks per popup: one closed
# while fullscreen reopens fullscreen.
set -euo pipefail

SOCKET=${POPUP_TOGGLE_SOCKET:-popup}
FS_KEY=${POPUP_TOGGLE_FS_KEY:-M-Enter}
SELF=$(realpath "${BASH_SOURCE[0]}")
POPUP_CONF="$HOME/.config/tmux/tmux.popup.conf"

pt() { tmux -L "$SOCKET" "$@"; }

# Session names can't contain '.' or ':', so cwd owners are a hash of the path.
hash_dir() { cksum <<<"$1" | cut -d' ' -f1; }

# Popup dimension spec ("90%" or cells) -> inner cells ($2 = client cells;
# the border takes 2).
cells() {
  local d=$1
  [[ $d == *% ]] && d=$(($2 * ${d%\%} / 100))
  echo $((d - 2))
}

# Popup session name wire format: <scope char><owner>-<name>. Chars are the
# scope initials, except server is "v" since "s" is session's. Names get the
# same '.'/':' cleaning as cwd owners get hashed (see hash_dir).
sname_clean() { printf '%s' "${1//[.:]/_}"; }
sname_encode() { printf '%s%s-%s' "$1" "$2" "$(sname_clean "$3")"; }
sname_owner() {
  local o=${1:1}
  printf '%s' "${o%%-*}"
}
sname_name() { printf '%s' "${1#*-}"; }

# Live owner ids per scope initial, one per line; must produce the same
# strings as the owner construction in main below. pane/window/session owners
# embed the main server's pid (the server owner is the pid): a restarted
# server reuses pane/window/session ids, so popups from a dead server must
# never match the new owners. cwd owners are pid-less path hashes — a
# directory's identity survives restarts. On a sessionless or dead main
# server these fail; that means "no owners", not an error.
alive_ids() {
  case $1 in
  p) tmux list-panes -a -F '#{pid}_#{pane_id}' ;;
  w) tmux list-windows -a -F '#{pid}_#{window_id}' ;;
  s) tmux list-sessions -F '#{pid}_#{session_id}' ;;
  v) tmux list-sessions -F '#{pid}' ;;
  c) tmux list-panes -a -F '#{pane_current_path}' | sort -u |
    while IFS= read -r p; do hash_dir "$p"; done ;;
  esac 2>/dev/null || true
}

# cwd popups may only be swept while the main server is up, else they'd never
# survive a restart. A sessionless server is ambiguous: closing the last
# window leaves the server idling until this very hook job exits, while
# kill-server takes it down despite us — wait a beat to tell them apart.
main_alive() {
  local out
  out=$(tmux list-sessions -F x 2>/dev/null) || return 1
  [[ -n $out ]] && return 0
  sleep 0.5
  tmux list-sessions &>/dev/null
}

gc() {
  local sessions s prefix sweep_cwd=1
  local -A alive=()
  sessions=$(pt list-sessions -F '#{session_name}' 2>/dev/null) || return 0
  main_alive || sweep_cwd=0
  while IFS= read -r s; do
    case $s in
    [pwsvc][0-9]*) prefix=${s:0:1} ;;
    *) continue ;;
    esac
    [[ $prefix == c && $sweep_cwd == 0 ]] && continue
    [[ -v alive[$prefix] ]] || alive[$prefix]=$(alive_ids "$prefix")
    grep -qxF "$(sname_owner "$s")" <<<"${alive[$prefix]}" ||
      pt kill-session -t "=$s" 2>/dev/null || true
  done <<<"$sessions"
}

# Copy the main server's popup-toggle bindings onto the popup server, so every
# popup key works inside every popup without having been pressed there first
# (while a popup is up, keys go to the popup server; the main binds are out of
# reach). -P smuggles in the popup session the key landed in.
#
# Runs once per popup-server lifetime, plus once per tmux.conf source (the
# only time the binds can change) — never on the popup-open hot path. The
# mirrored key list is stashed in @popup_binds, which doubles as the
# "already mirrored" marker and as the list to unbind from when a key is
# dropped from tmux.conf. Everything ships as one batched command.
mirror() {
  local line key cmd args old k batch=() new=""
  local -r me=${SELF##*/}
  # No server, nothing to mirror onto: the next popup open handles it.
  old=$(pt show-options -gqv @popup_binds 2>/dev/null) || return 0
  while IFS= read -r line; do
    [[ $line =~ ^bind-key[[:space:]]+-T[[:space:]]+root[[:space:]]+([^[:space:]]+)[[:space:]]+run-shell[[:space:]]+(.*)$ ]] || continue
    key=${BASH_REMATCH[1]} cmd=${BASH_REMATCH[2]}
    cmd=${cmd#-b }
    cmd=${cmd#\"} cmd=${cmd%\"}
    [[ $cmd == *"$me"* ]] || continue
    args=""
    [[ $cmd == *" "* ]] && args=" ${cmd#* }"
    new+="$key "
    batch+=(bind-key -n "$key" run-shell -b "'$SELF' -P '#{session_name}'$args" ";")
  done < <(tmux list-keys -T root 2>/dev/null || true)
  for k in $old; do # keys that left tmux.conf since the last mirror
    [[ " $new" == *" $k "* ]] && continue
    batch+=(unbind-key -n "$k" ";")
  done
  # Always last, so @popup_binds is never empty and thus always a valid marker.
  batch+=(bind-key -n "$FS_KEY" run-shell -b "'$SELF' --fs '#{session_name}'" ";")
  new+="$FS_KEY "
  batch+=(set-option -g @popup_binds "$new")
  pt "${batch[@]}"
}

# Detach a popup's client and wait for it to be fully gone: a reopen silently
# no-ops until the old popup is, plus a beat more.
close_wait() {
  pt detach-client -s "=$1"
  for _ in {1..20}; do
    [[ -n $(pt list-clients -t "=$1" 2>/dev/null) ]] || break
    sleep 0.05
  done
  sleep 0.05
}

if [[ "${1:-}" == "--gc" ]]; then
  gc
  exit 0
fi

# Invoked from tmux.conf after the popup binds, to refresh a popup server that
# is already up. No-ops when it isn't — show-options won't start one.
if [[ "${1:-}" == "--mirror" ]]; then
  mirror
  exit 0
fi

# Invoked from the popup server's FS_KEY binding: a popup can't be resized in
# place, so close it and reopen it at the other size on the client it came
# from. Size/client state was stashed in the popup session's options by main.
if [[ "${1:-}" == "--fs" ]]; then
  s=$2
  # "=$s:" not "=$s": these take a target-pane, which won't parse a bare "=name"
  IFS=' ' read -r fs w h client \
    < <(pt display-message -p -t "=$s:" '#{@popup_fs} #{@popup_w} #{@popup_h} #{@popup_client}')
  [[ -n $client ]] || exit 0 # options missing: leave the popup alone
  if [[ $fs == 1 ]]; then
    pt set-option -t "=$s:" @popup_fs 0
  else
    pt set-option -t "=$s:" @popup_fs 1
    w=100% h=100%
  fi
  close_wait "$s"
  exec env -u TMUX tmux display-popup -c "$client" -w "$w" -h "$h" -T " $(sname_name "$s") " -E -- \
    tmux -L "$SOCKET" new-session -A -s "$s"
fi

# Original argv, re-played against the main server when switching popups.
orig=("$@")

sock=${TMUX:-}
sock=${sock%%,*}
inside=0
[[ "${sock##*/}" == "$SOCKET" ]] && inside=1

scope=session name=scratch width=90% height=90% cursess= mclient=
while getopts :s:n:w:h:k:P:C: opt; do
  case $opt in
  s) scope=$OPTARG ;;
  n) name=$OPTARG ;;
  w) width=$OPTARG ;;
  h) height=$OPTARG ;;
  k) ;; # obsolete (popup-side close key), ignored for old configs
  P) cursess=$OPTARG ;; # internal: popup session the key was pressed in
  C) mclient=$OPTARG ;; # internal: main-server client to open the popup on
  *)
    echo "usage: popup-toggle.sh [-s pane|window|session|server|cwd|global] [-n name] [-w width] [-h height] [command...]" >&2
    exit 1
    ;;
  esac
done
shift $((OPTIND - 1))

case $scope in
pane) sc=p ;;
window) sc=w ;;
session) sc=s ;;
server) sc=v ;;
cwd) sc=c ;;
global) sc=g ;;
*)
  echo "popup-toggle.sh: bad scope '$scope' (pane|window|session|server|cwd|global)" >&2
  exit 1
  ;;
esac

# Invoked from inside the popup server (a mirrored binding, or by hand from a
# popup shell): the current popup's own key just closes it; a different
# popup's key closes it, then re-plays this invocation against the main
# server so that popup opens in its place. Scope char + name identify the
# popup — the owner can't differ, the main client hasn't moved.
if [[ $inside == 1 ]]; then
  cur=${cursess:-$(tmux display-message -p '#{client_session}')}
  [[ -n $cur ]] || exit 0
  if [[ ${cur:0:1} == "$sc" && $(sname_name "$cur") == "$(sname_clean "$name")" ]]; then
    exec tmux -L "$SOCKET" detach-client -s "=$cur"
  fi
  client=$(pt display-message -p -t "=$cur:" '#{@popup_client}' 2>/dev/null) || client=
  [[ -n $client ]] || exec tmux -L "$SOCKET" detach-client -s "=$cur"
  close_wait "$cur"
  exec env -u TMUX "$SELF" -C "$client" ${orig[@]+"${orig[@]}"}
fi

# One round trip for everything a scope may need; path last, it can have
# spaces. A popup-switch re-exec has no client of its own, so -C targets the
# client the old popup came from.
IFS=' ' read -r srv sess win pane ctty cw ch cwd \
  < <(tmux display-message ${mclient:+-c "$mclient"} -p '#{pid} #{session_id} #{window_id} #{pane_id} #{client_tty} #{client_width} #{client_height} #{pane_current_path}')
case $sc in
p) owner="${srv}_${pane}" ;;
w) owner="${srv}_${win}" ;;
s) owner="${srv}_${sess}" ;;
v) owner="$srv" ;;
c) owner=$(hash_dir "$cwd") ;;
g) owner="" ;;
esac
sname=$(sname_encode "$sc" "$owner" "$name")

gc # sweep orphans on every toggle too, in case a hook was missed

# -f only takes effect when the popup server first starts; the conf sets
# exit-empty off so the server (and the bindings below) outlives its sessions.
# A server that just started has no marker option, so it needs the binds;
# otherwise tmux.conf's --mirror has kept them current. One round trip.
[[ -n $(pt -f "$POPUP_CONF" start-server \; show-options -gqv @popup_binds) ]] || mirror

# Pre-create the session (sized like the popup will be) so the fullscreen
# toggle's per-popup state can live in its session options. An existing
# session keeps its @popup_fs, so a popup closed while fullscreen reopens
# fullscreen.
pt has-session -t "=$sname" 2>/dev/null ||
  pt new-session -d -s "$sname" -c "$cwd" \
    -x "$(cells "$width" "$cw")" -y "$(cells "$height" "$ch")" "$@" \; \
    set-option -t "=$sname:" @popup_fs 0
# set-option takes a target-pane, which won't parse a bare "=name" — hence ":".
# The @popup_fs read rides the same round trip.
fs=$(pt set-option -t "=$sname:" @popup_w "$width" \; \
  set-option -t "=$sname:" @popup_h "$height" \; \
  set-option -t "=$sname:" @popup_client "$ctty" \; \
  display-message -p -t "=$sname:" '#{@popup_fs}')

[[ $fs == 1 ]] && width=100% height=100%

exec tmux display-popup -c "$ctty" -w "$width" -h "$height" -T " $name " -E -- \
  tmux -L "$SOCKET" new-session -A -s "$sname" -c "$cwd" "$@"
