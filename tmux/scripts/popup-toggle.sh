#!/usr/bin/env bash
#
# Toggleable popups backed by detached sessions on a separate tmux server, so
# they never appear in the main session list. Two frontends share this script:
#
#   tmux   keys bound in tmux.conf; popups are tmux display-popups on the
#          popup server "popup"
#   herdr  keys bound in herdr's config.toml as type = "shell" commands;
#          popups are herdr session-modal popups, opened through the local
#          popup-toggle plugin, on the popup server "popup-herdr"
#
# The frontend is picked from the environment: HERDR_* context from a herdr
# key or plugin hook means herdr, $TMUX means tmux.
#
# Usage: popup-toggle.sh [-s scope] [-n name] [-w width] [-h height]
#                     [command...]
#        popup-toggle.sh --gc | --mirror | --attach
#
#   -s scope   (default: session). A scoped popup lives as long as its owner:
#      when the owner closes, the popup session is killed by --gc (wired to
#      tmux hooks / herdr plugin events). herdr names are accepted too:
#        pane      pane
#        window    tab
#        session   workspace
#        server    server — shared by every session/workspace, dies with it
#        cwd       cwd    — shared by all panes in the same working directory,
#                           lives while any pane still has that cwd
#        global    global — shared everywhere, never GC'd
#   -n name    popup name, allows several popups per scope (default: scratch)
#   command    run in the popup session (default: your shell)
#
# Every frontend key bound to this script is mirrored into the popup server,
# so inside any popup its own key closes it and any other popup's key swaps
# the current popup for that one — no key has to have been used before.
#
# Inside any popup, M-Enter (POPUP_TOGGLE_FS_KEY) toggles the popup between
# its default size and full screen. The state sticks per popup: one closed
# while fullscreen reopens fullscreen.
set -euo pipefail

TMUX_SOCK=${POPUP_TOGGLE_SOCKET:-popup}
HERDR_SOCK="$TMUX_SOCK-herdr"
FS_KEY=${POPUP_TOGGLE_FS_KEY:-M-Enter}
SELF=$(realpath "${BASH_SOURCE[0]}")
POPUP_CONF="$HOME/.config/tmux/tmux.popup.conf"
HERDR=${HERDR_BIN_PATH:-herdr}
HERDR_CONF=${HERDR_CONFIG_PATH:-$HOME/.config/herdr/config.toml}
PLUGIN_ID=popup-toggle

# Frontend and whether we run inside a popup server. Inside is decided first:
# the popup server's environment is whatever started it, so HERDR_* leaks
# into its run-shell commands under herdr. Then herdr's per-key context
# (only herdr keys/hooks set it) beats a $TMUX that leaked into a herdr
# server started from tmux; a plain HERDR_ENV=1 pane shell counts as herdr.
sock=${TMUX:-} sock=${sock%%,*} sock=${sock##*/}
inside=0
case $sock in
"$TMUX_SOCK") inside=1 front=tmux ;;
"$HERDR_SOCK") inside=1 front=herdr ;;
*)
  if [[ -n ${HERDR_ACTIVE_PANE_ID:-}${HERDR_PLUGIN_ID:-} ]]; then front=herdr
  elif [[ -n ${TMUX:-} ]]; then front=tmux
  elif [[ -n ${HERDR_ENV:-} ]]; then front=herdr
  else front=tmux; fi
  ;;
esac
[[ $front == herdr ]] && SOCKET=$HERDR_SOCK || SOCKET=$TMUX_SOCK

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
# scope initials, except server is "v" since "s" is session's. Names and
# herdr ids ("wH:p1") get '.'/':' cleaned the way cwd owners get hashed.
sname_clean() { printf '%s' "${1//[.:]/_}"; }
sname_encode() { printf '%s%s-%s' "$1" "$2" "$(sname_clean "$3")"; }
sname_owner() {
  local o=${1:1}
  printf '%s' "${o%%-*}"
}
sname_name() { printf '%s' "${1#*-}"; }

# --- herdr context -----------------------------------------------------------

# Key commands get HERDR_ACTIVE_*; plugin hooks and pane shells get HERDR_*.
herdr_ctx() {
  hws=${HERDR_ACTIVE_WORKSPACE_ID:-${HERDR_WORKSPACE_ID:-}}
  htab=${HERDR_ACTIVE_TAB_ID:-${HERDR_TAB_ID:-}}
  hpane=${HERDR_ACTIVE_PANE_ID:-${HERDR_PANE_ID:-}}
  hcwd=${HERDR_ACTIVE_PANE_CWD:-$PWD}
}

# A herdr server run is identified by its socket file (inode + creation
# time): a restarted server makes a new one and reuses pane/tab/workspace
# ids, the same problem the tmux pid solves. Empty when no server is up.
# GNU stat first: its -f means filesystem status and succeeds, while BSD
# stat rejects -c.
herdr_srv() {
  local s=${HERDR_SOCKET_PATH:-$HOME/.config/herdr/herdr.sock}
  stat -c '%i_%Z' "$s" 2>/dev/null || stat -f '%i_%B' "$s" 2>/dev/null || true
}

# Values of string key $1 in the JSON that `herdr $2 list` prints. Ids never
# contain quotes; paths may, so cwd values get the escaped-char treatment.
herdr_ids() {
  "$HERDR" "$2" list 2>/dev/null |
    grep -o -E "\"$1\":\"([^\"\\\\]|\\\\.)*\"" |
    sed -E "s/^\"$1\":\"//; s/\"\$//; s#\\\\([\"\\\\/])#\\1#g" | sort -u
}

# --- gc ----------------------------------------------------------------------

# Live owner ids per scope initial, one per line; must produce the same
# strings as the owner construction in main below. pane/window/session owners
# embed the main server's identity (the server owner is that identity): a
# restarted server reuses pane/window/session ids, so popups from a dead
# server must never match the new owners. cwd owners are server-less path
# hashes — a directory's identity survives restarts. On a sessionless or dead
# main server these fail; that means "no owners", not an error.
alive_ids() {
  local srv i
  case $front:$1 in
  tmux:p) tmux list-panes -a -F '#{pid}_#{pane_id}' ;;
  tmux:w) tmux list-windows -a -F '#{pid}_#{window_id}' ;;
  tmux:s) tmux list-sessions -F '#{pid}_#{session_id}' ;;
  tmux:v) tmux list-sessions -F '#{pid}' ;;
  tmux:c) tmux list-panes -a -F '#{pane_current_path}' | sort -u |
    while IFS= read -r p; do hash_dir "$p"; done ;;
  herdr:[pws])
    srv=$(herdr_srv)
    [[ -n $srv ]] || return 0
    case $1 in p) i=$(herdr_ids pane_id pane) ;; w) i=$(herdr_ids tab_id tab) ;; s) i=$(herdr_ids workspace_id workspace) ;; esac
    [[ -n $i ]] && while IFS= read -r p; do printf '%s_%s\n' "$srv" "$(sname_clean "$p")"; done <<<"$i"
    ;;
  herdr:v) herdr_srv ;;
  herdr:c) { herdr_ids cwd pane; herdr_ids foreground_cwd pane; } | sort -u |
    while IFS= read -r p; do hash_dir "$p"; done ;;
  esac 2>/dev/null || true
}

# cwd popups may only be swept while the main server is up, else they'd never
# survive a restart. A sessionless tmux server is ambiguous: closing the last
# window leaves the server idling until this very hook job exits, while
# kill-server takes it down despite us — wait a beat to tell them apart.
main_alive() {
  local out
  if [[ $front == herdr ]]; then
    "$HERDR" workspace list &>/dev/null
    return
  fi
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

# --- key mirroring -----------------------------------------------------------

# Frontend keys bound to this script, one per line: <table>\t<key>\t<args>.
# args keep their leading space (or are empty).
binds_tmux() {
  local line key cmd args
  local -r me=${SELF##*/}
  while IFS= read -r line; do
    [[ $line =~ ^bind-key[[:space:]]+-T[[:space:]]+root[[:space:]]+([^[:space:]]+)[[:space:]]+run-shell[[:space:]]+(.*)$ ]] || continue
    key=${BASH_REMATCH[1]} cmd=${BASH_REMATCH[2]}
    cmd=${cmd#-b }
    cmd=${cmd#\"} cmd=${cmd%\"}
    [[ $cmd == *"$me"* ]] || continue
    args=""
    [[ $cmd == *" "* ]] && args=" ${cmd#* }"
    printf 'root\t%s\t%s\n' "$key" "$args"
  done < <(tmux list-keys -T root 2>/dev/null || true)
}

# [[keys.command]] blocks of config.toml whose shell command runs this script.
# awk yields <key>\t<command> with TOML basic-string escapes undone.
binds_herdr() {
  local key cmd args tk
  local -r me=${SELF##*/}
  while IFS=$'\t' read -r key cmd; do
    args=${cmd#*"$me"}
    args=${args#\"} args=${args#\'}
    [[ -z $args || $args == " "* ]] || continue # "popup-toggle.shx"?
    tk=$(tmux_key "$key") || continue
    printf '%s\t%s\n' "$tk" "$args"
  done < <(awk -v me="$me" '
    function val(s,  i, c, out, esc) {
      sub(/^[^"]*"/, "", s); out = ""; esc = 0
      for (i = 1; i <= length(s); i++) {
        c = substr(s, i, 1)
        if (esc) { out = out c; esc = 0 }
        else if (c == "\\") esc = 1
        else if (c == "\"") break
        else out = out c
      }
      return out
    }
    function flush() {
      if (inblk && type == "shell" && index(cmd, me)) print key "\t" cmd
      inblk = 0; key = ""; type = ""; cmd = ""
    }
    /^[[:space:]]*\[\[keys\.command\]\]/ { flush(); inblk = 1; next }
    /^[[:space:]]*\[/ { flush(); next }
    inblk && /^[[:space:]]*key[[:space:]]*=/ { key = val($0) }
    inblk && /^[[:space:]]*type[[:space:]]*=/ { type = val($0) }
    inblk && /^[[:space:]]*command[[:space:]]*=/ { cmd = val($0) }
    END { flush() }
  ' "$HERDR_CONF" 2>/dev/null || true)
}

# herdr key spec ("alt+g", "prefix+shift+g") -> <table>\t<tmux key>. prefix
# keys go in the popup-close table that tmux.popup.conf enters on the prefix.
# Fails on keys a terminal can't deliver (super/cmd) or names not mapped.
tmux_key() {
  local spec=${1,,} parts part mods="" table=root base n
  IFS='+' read -r -a parts <<<"$spec"
  n=${#parts[@]}
  base=${parts[n - 1]}
  for part in ${parts[@]+"${parts[@]:0:n-1}"}; do
    case $part in
    ctrl | control) mods+="C-" ;;
    alt | opt | option | meta) mods+="M-" ;;
    shift) mods+="S-" ;;
    prefix) table=popup-close ;;
    *) return 1 ;;
    esac
  done
  case $base in
  enter | return) base=Enter ;;
  space) base=Space ;;
  tab) base=Tab ;;
  esc | escape) base=Escape ;;
  backspace) base=BSpace ;;
  delete | del) base=DC ;;
  insert) base=IC ;;
  pageup) base=PPage ;;
  pagedown) base=NPage ;;
  up | down | left | right | home | end | f[1-9] | f1[0-2]) base=${base^} ;;
  ?) ;;
  *) return 1 ;;
  esac
  if [[ $mods == *S-* && $base == [a-z] ]]; then # shift+letter is the capital
    mods=${mods//S-/} base=${base^}
  fi
  printf '%s\t%s%s\n' "$table" "$mods" "$base"
}

conf_mtime() { stat -L -c %Y "$HERDR_CONF" 2>/dev/null || stat -L -f %m "$HERDR_CONF" 2>/dev/null || true; }

# Copy the frontend's popup-toggle bindings onto the popup server, so every
# popup key works inside every popup without having been pressed there first
# (while a popup is up, keys go to the popup server; the frontend's binds are
# out of reach). -P smuggles in the popup session the key landed in.
#
# Runs once per popup-server lifetime, plus whenever the binds can change:
# on tmux.conf source (--mirror) or when config.toml's mtime moved (checked
# on open). Mirrored keys are stashed in @popup_binds (root table) and
# @popup_pbinds (popup-close table); @popup_binds doubles as the "already
# mirrored" marker and both are the lists to unbind from when a key is
# dropped. Everything ships as one batched command.
mirror() {
  local table key args old pold k batch=() new="" pnew=""
  # No server, nothing to mirror onto: the next popup open handles it.
  old=$(pt show-options -gqv @popup_binds 2>/dev/null) || return 0
  pold=$(pt show-options -gqv @popup_pbinds 2>/dev/null) || true
  while IFS=$'\t' read -r table key args; do
    [[ $table == root ]] && new+="$key " || pnew+="$key "
    batch+=(bind-key -T "$table" "$key" run-shell -b "'$SELF' -P '#{session_name}'$args" ";")
  done < <("binds_$front")
  for k in $old; do # keys that left the frontend config since the last mirror
    [[ " $new" == *" $k "* ]] && continue
    batch+=(unbind-key -T root "$k" ";")
  done
  for k in $pold; do
    [[ " $pnew" == *" $k "* ]] && continue
    batch+=(unbind-key -T popup-close "$k" ";")
  done
  # Always last, so @popup_binds is never empty and thus always a valid marker.
  batch+=(bind-key -T root "$FS_KEY" run-shell -b "'$SELF' --fs '#{session_name}'" ";")
  new+="$FS_KEY "
  [[ $front == herdr ]] && batch+=(set-option -g @popup_conf_mtime "$(conf_mtime)" ";")
  batch+=(set-option -g @popup_pbinds "$pnew" ";" set-option -g @popup_binds "$new")
  pt "${batch[@]}"
}

# --- popup open/close --------------------------------------------------------

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

# herdr: open a popup showing session $1 at its stored size. The plugin's
# pane command is this script's --attach, told the session through the
# environment. The popup's border title is the pane entry's title, so the
# entry named like the popup is tried first (the manifest has one per known
# name) and the untitled "popup" entry is the fallback. herdr refuses
# (ui_busy) while another modal — the popup we just closed included — is
# still up, so retry for a while.
herdr_open() {
  local s=$1 fs w h out entry
  IFS=' ' read -r fs w h < <(pt display-message -p -t "=$s:" '#{@popup_fs} #{@popup_w} #{@popup_h}')
  [[ $fs == 1 ]] && w=100% h=100%
  entry=$(sname_name "$s")
  for _ in {1..40}; do
    if out=$("$HERDR" plugin pane open --plugin "$PLUGIN_ID" --entrypoint "$entry" \
      --placement popup --width "$w" --height "$h" \
      --env "POPUP_TOGGLE_ATTACH=$s" 2>&1); then
      [[ $out == *ui_busy* ]] || return 0
    elif [[ $out == *invalid_plugin_entrypoint* || $out == *plugin_pane_not_found* ]]; then
      [[ $entry != popup ]] || { printf 'popup-toggle.sh: %s\n' "$out" >&2; return 1; }
      entry=popup
      continue
    elif [[ $out != *ui_busy* ]]; then
      printf 'popup-toggle.sh: %s\n' "$out" >&2
      return 1
    fi
    sleep 0.05
  done
  printf 'popup-toggle.sh: herdr popup stayed busy\n' >&2
  return 1
}

# --- modes -------------------------------------------------------------------

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

# The herdr plugin's popup pane command: attach to the session herdr_open
# named. The popup lives exactly as long as this client.
if [[ "${1:-}" == "--attach" ]]; then
  exec tmux -L "$HERDR_SOCK" attach-session -t "=${POPUP_TOGGLE_ATTACH:?}"
fi

# Invoked from the popup server's FS_KEY binding: a popup can't be resized in
# place, so close it and reopen it at the other size. Size/client state was
# stashed in the popup session's options by main.
if [[ "${1:-}" == "--fs" ]]; then
  s=$2
  # "=$s:" not "=$s": these take a target-pane, which won't parse a bare "=name"
  IFS=' ' read -r fs w h client \
    < <(pt display-message -p -t "=$s:" '#{@popup_fs} #{@popup_w} #{@popup_h} #{@popup_client}')
  [[ -n $w ]] || exit 0 # options missing: leave the popup alone
  if [[ $fs == 1 ]]; then
    pt set-option -t "=$s:" @popup_fs 0
  else
    pt set-option -t "=$s:" @popup_fs 1
    w=100% h=100%
  fi
  if [[ $front == herdr ]]; then
    close_wait "$s"
    herdr_open "$s"
    exit
  fi
  [[ -n $client ]] || exit 0
  close_wait "$s"
  exec env -u TMUX tmux display-popup -c "$client" -w "$w" -h "$h" -T " $(sname_name "$s") " -E -- \
    tmux -L "$SOCKET" new-session -A -s "$s"
fi

# Original argv, re-played against the frontend when switching popups.
orig=("$@")

scope=session name=scratch width=90% height=90% cursess= mclient=
while getopts :s:n:w:h:k:P:C: opt; do
  case $opt in
  s) scope=$OPTARG ;;
  n) name=$OPTARG ;;
  w) width=$OPTARG ;;
  h) height=$OPTARG ;;
  k) ;; # obsolete (popup-side close key), ignored for old configs
  P) cursess=$OPTARG ;; # internal: popup session the key was pressed in
  C) mclient=$OPTARG ;; # internal: tmux main-server client to open the popup on
  *)
    echo "usage: popup-toggle.sh [-s pane|window|session|server|cwd|global] [-n name] [-w width] [-h height] [command...]" >&2
    exit 1
    ;;
  esac
done
shift $((OPTIND - 1))

case $scope in
pane) sc=p ;;
window | tab) sc=w ;;
session | workspace) sc=s ;;
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
# popup's key closes it, then re-plays this invocation against the frontend
# so that popup opens in its place. Scope char + name identify the popup —
# the owner can't differ, the frontend's focus hasn't moved (herdr's popup
# is modal; the context it was opened with is stashed in its session).
if [[ $inside == 1 ]]; then
  cur=${cursess:-$(tmux display-message -p '#{client_session}')}
  [[ -n $cur ]] || exit 0
  if [[ ${cur:0:1} == "$sc" && $(sname_name "$cur") == "$(sname_clean "$name")" ]]; then
    exec tmux -L "$SOCKET" detach-client -s "=$cur"
  fi
  if [[ $front == herdr ]]; then
    { IFS=' ' read -r ws tab pane; IFS= read -r cwd; } < <(pt display-message -p -t "=$cur:" '#{@popup_ctx}' \; display-message -p -t "=$cur:" '#{@popup_cwd}' 2>/dev/null) || true
    [[ -n ${pane:-} ]] || exec tmux -L "$SOCKET" detach-client -s "=$cur"
    close_wait "$cur"
    exec env -u TMUX HERDR_ACTIVE_WORKSPACE_ID="$ws" HERDR_ACTIVE_TAB_ID="$tab" \
      HERDR_ACTIVE_PANE_ID="$pane" HERDR_ACTIVE_PANE_CWD="$cwd" \
      "$SELF" ${orig[@]+"${orig[@]}"}
  fi
  client=$(pt display-message -p -t "=$cur:" '#{@popup_client}' 2>/dev/null) || client=
  [[ -n $client ]] || exec tmux -L "$SOCKET" detach-client -s "=$cur"
  close_wait "$cur"
  exec env -u TMUX "$SELF" -C "$client" ${orig[@]+"${orig[@]}"}
fi

# Owner ids: see alive_ids for the matching live-id construction.
ctty= cw= ch=
if [[ $front == herdr ]]; then
  herdr_ctx
  srv=$(herdr_srv)
  cwd=$hcwd
  case $sc in
  p) id=$hpane ;;
  w) id=$htab ;;
  s) id=$hws ;;
  *) id=x ;;
  esac
  if [[ -z $srv || -z $id ]]; then
    echo "popup-toggle.sh: no herdr context for scope '$scope' (run from a herdr key binding)" >&2
    exit 1
  fi
  case $sc in
  p) owner="${srv}_$(sname_clean "$hpane")" ;;
  w) owner="${srv}_$(sname_clean "$htab")" ;;
  s) owner="${srv}_$(sname_clean "$hws")" ;;
  v) owner="$srv" ;;
  c) owner=$(hash_dir "$cwd") ;;
  g) owner="" ;;
  esac
else
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
fi
sname=$(sname_encode "$sc" "$owner" "$name")

gc # sweep orphans on every toggle too, in case a hook was missed

# -f only takes effect when the popup server first starts; the conf sets
# exit-empty off so the server (and the bindings below) outlives its sessions.
# A server that just started has no marker option, so it needs the binds;
# otherwise tmux.conf's --mirror has kept them current, or — herdr has no
# config-reload hook — config.toml's mtime says whether they're stale. One
# round trip. Under herdr the per-key context is scrubbed from the server's
# environment, so popup shells don't inherit stale HERDR_ACTIVE_* ids.
scrub=()
[[ $front == herdr ]] && scrub=(-u HERDR_ACTIVE_WORKSPACE_ID -u HERDR_ACTIVE_TAB_ID -u HERDR_ACTIVE_PANE_ID -u HERDR_ACTIVE_PANE_CWD)
{ IFS= read -r marker; IFS= read -r mtime; } < <(env ${scrub[@]+"${scrub[@]}"} tmux -L "$SOCKET" -f "$POPUP_CONF" start-server \; \
  show-options -gqv @popup_binds \; show-options -gqv @popup_conf_mtime; echo; echo) || true
if [[ -z $marker ]]; then
  mirror
elif [[ $front == herdr && $mtime != "$(conf_mtime)" ]]; then
  mirror
fi

# Pre-create the session (sized like the popup will be, when the frontend
# tells us) so the fullscreen toggle's per-popup state can live in its
# session options. An existing session keeps its @popup_fs, so a popup
# closed while fullscreen reopens fullscreen.
size=()
[[ -n $cw ]] && size=(-x "$(cells "$width" "$cw")" -y "$(cells "$height" "$ch")")
pt has-session -t "=$sname" 2>/dev/null ||
  pt new-session -d -s "$sname" -c "$cwd" ${size[@]+"${size[@]}"} "$@" \; \
    set-option -t "=$sname:" @popup_fs 0
# set-option takes a target-pane, which won't parse a bare "=name" — hence ":".
# The @popup_fs read rides the same round trip.
opts=(set-option -t "=$sname:" @popup_w "$width" \; set-option -t "=$sname:" @popup_h "$height" \;)
if [[ $front == herdr ]]; then
  opts+=(set-option -t "=$sname:" @popup_ctx "$hws $htab $hpane" \; set-option -t "=$sname:" @popup_cwd "$cwd" \;)
else
  opts+=(set-option -t "=$sname:" @popup_client "$ctty" \;)
fi
fs=$(pt "${opts[@]}" display-message -p -t "=$sname:" '#{@popup_fs}')

if [[ $front == herdr ]]; then
  herdr_open "$sname"
  exit
fi

[[ $fs == 1 ]] && width=100% height=100%

exec tmux display-popup -c "$ctty" -w "$width" -h "$height" -T " $name " -E -- \
  tmux -L "$SOCKET" new-session -A -s "$sname" -c "$cwd" "$@"
