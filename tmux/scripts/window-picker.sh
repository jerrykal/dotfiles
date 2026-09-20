#!/usr/bin/env bash

# Pick a window of the current session with fzf, most recently used first.
# Moving the selection switches to the window (live preview); Esc puts you
# back where you started. Ctrl-x kills the selected window.
#
# The cursor starts on the second row — the last window you used, since the
# first row is the one you are on — so opening and pressing enter is a
# back-and-forth toggle. It has to hang off `load` (`start` fires before the
# list is read) and say pos(2) rather than a direction, which would depend on
# whether --layout reverse is in effect.
#
# Browsing leaves no trace: @picker_busy freezes the @mru stamps (see the
# session-window-changed hook in tmux.conf) and the window stack tmux's own
# last-window rides on is replayed on the way out. The one thing replaying
# can't undo is an entry that wasn't there before — selecting is the only way
# to touch the stack, and it can only push — so previewing from a session with
# no history at all leaves the last window you looked at as its last-window.

# Re-exec under `mise exec` so fzf resolves to a real binary: tmux run-shell
# finds it as a mise shim, which re-resolves the whole toolset on every call.
if [[ -z "${__MISE_EXEC:-}" ]] && command -v mise >/dev/null 2>&1; then
  __MISE_EXEC=1 exec mise exec -- "${BASH_SOURCE[0]}" "$@"
fi

# mapfile and the rest are bash 4; macOS ships 3.2, so say so rather than
# failing halfway through a switch with @picker_busy left set.
((BASH_VERSINFO[0] >= 4)) || {
  tmux display-message "window-picker: needs bash 4+, found $BASH_VERSION"
  exit 1
}

max_height=15
max_name=24
max_path=32
us=$'\x1f'

# US-separated, and ids rather than names: session names can hold spaces, and
# a bare window id resolves against any session the window is linked into.
IFS=$us read -r sid session orig orig_pane \
  < <(tmux display-message -p "#{session_id}${us}#{session_name}${us}#{window_id}${us}#{pane_id}")
[[ -n "$sid" ]] || exit 0

# Hooks fire after the command list that triggered them, so the flag has to be
# set in its own call to cover the very first switch.
tmux set -g @picker_busy 1
cleanup() { # runs once, however we leave
  [[ -n "${cleaned:-}" ]] && return
  cleaned=1
  [[ -z "${landed:-}" ]] && restore
  tmux set -g @picker_busy 0
}
trap cleanup EXIT
trap 'cleanup; exit 130' INT TERM HUP

# The stack, oldest first: replaying it in that order rebuilds it exactly,
# since selecting a window moves it back to the top. Index 0 is the current
# window (and any window never selected), which is why it can't order the list.
mapfile -t stack < <(
  tmux list-windows -t "$sid" -F "#{window_stack_index}${us}#{window_id}" |
    awk -F"$us" '$1 > 0' | sort -rn | cut -d"$us" -f2
)

# A window the hook never stamped falls back to window_activity, which
# selecting a window bumps — so the preview alone could reorder it. If any
# window is unstamped, renumber the whole session in the order the list would
# have shown it (oldest first) and the order stops moving. Renumbering all of
# them, not just the strays, keeps a fresh stamp from jumping over an old one.
seed_stamps() {
  local row id cmds=() rows stray=0
  # Sorted the way the list is, but oldest first. The current window sorts
  # last whatever its stamp says: it is the one you are on.
  mapfile -t rows < <(
    tmux list-windows -t "$sid" \
      -F "#{?window_active,9999999999,#{@mru}}${us}#{window_activity}${us}#{window_id}${us}#{@mru}" |
      sort -t"$us" -k1,1n -k2,2n
  )
  for row in "${rows[@]}"; do [[ "$row" == *"$us" ]] && stray=1; done
  ((stray)) || return 0 # every window already carries a stamp
  for row in "${rows[@]}"; do
    id=$(cut -d"$us" -f3 <<<"$row")
    cmds+=(set -gF @mru_seq "#{e|+|:#{@mru_seq},1}" ';' setw -Ft "$sid:$id" @mru "#{@mru_seq}" ';')
  done
  tmux "${cmds[@]:0:${#cmds[@]}-1}"
}
seed_stamps

# Replay as one tmux command list: the server redraws once at the end, so the
# windows it walks through never reach the screen. A command that fails aborts
# the rest of the list, so dead windows are dropped first — including the
# launching one, which anything from another client to ctrl-x can take away.
build_replay() {
  local id
  alive=$'\n'$(tmux list-windows -t "$sid" -F '#{window_id}' 2>/dev/null)$'\n'
  if [[ "$alive" != *$'\n'"$orig"$'\n'* ]]; then
    orig=$(tmux list-windows -t "$sid" -F '#{?window_active,#{window_id},}' 2>/dev/null | grep .)
    orig_pane=$(tmux list-panes -t "$sid:$orig" -F '#{?pane_active,#{pane_id},}' 2>/dev/null | grep .)
  fi
  replay=()
  [[ -n "$orig" ]] || return 1 # the whole session went away
  for id in "${stack[@]}"; do
    [[ "$alive" == *$'\n'"$id"$'\n'* ]] || continue
    replay+=(select-window -t "$sid:$id" ';')
  done
  replay+=(select-window -t "$sid:$orig")
}

restore() { build_replay && tmux "${replay[@]}" 2>/dev/null; }

list_windows() {
  tmux list-windows -t "$sid" -F "#{@mru}${us}#{window_activity}${us}#{window_id}${us}#{window_index}${us}#{window_name}${us}#{window_panes}${us}#{window_zoomed_flag}${us}#{pane_current_command}${us}#{pane_current_path}" |
    while IFS=$us read -r mru activity id index name panes zoomed cmd path; do
      ((${#name} > max_name)) && name="${name:0:max_name-1}…"
      path=${path/#"$HOME"/\~}
      ((${#path} > max_path)) && path="…${path: -(max_path - 1)}"
      flags=''
      ((panes > 1)) && flags=" ${panes}p"
      ((zoomed)) && flags+=" 󰊓"
      printf '%s\t%s\t%s\t\033[33m%2s\033[0m %-*s\033[2m%-4s\033[0m \033[2m%s\033[0m  \033[2;3m%s\033[0m\n' \
        "${mru:-0}" "$activity" "$id" "$index" "$max_name" "$name" "$flags" "$cmd" "$path"
    done |
    sort -t$'\t' -k1,1nr -k2,2nr | cut -f3-
}

entries=$(list_windows)
[[ -n "$entries" ]] || exit 0

while :; do
  height=$(($(wc -l <<<"$entries") + 4))
  ((height > max_height)) && height=$max_height
  width=$(sed $'s/\033\[[0-9;]*m//g' <<<"$entries" |
    awk -F'\t' '{ if (length($2) > w) w = length($2) } END { print w + 8 }')
  ((width < 30)) && width=30

  mapfile -t out < <(
    fzf --tmux="$width,$height" <<<"$entries" \
      --no-sort --ansi --border-label " Windows ($session) " --prompt '> ' \
      --delimiter '\t' --with-nth 2.. --accept-nth 1 \
      --expect=ctrl-x \
      --bind 'load:pos(2)' \
      --bind "focus:execute-silent(tmux select-window -t '$sid':{1})"
  )

  if [[ "${out[0]:-}" == ctrl-x ]]; then
    [[ -n "${out[1]:-}" ]] && tmux kill-window -t "${out[1]}" 2>/dev/null
    entries=$(list_windows)
    [[ -n "$entries" ]] || exit 0 # session died with its last window
    continue
  fi

  target=${out[1]:-}
  build_replay || exit 0
  # Cancel, or a target that died while we were looking at the list: the exit
  # trap puts the preview back.
  [[ -n "$target" && "$alive" == *$'\n'"$target"$'\n'* ]] || exit 0

  # Land on the target from the restored stack, and write the history by hand:
  # both hooks are still frozen (they run after this command list), so the
  # @mru stamp and the last-pane pair are ours to set. The counter is bumped
  # inside the list so two pickers can't hand out the same stamp.
  land=(select-window -t "$sid:$target" ';'
    set -gF @mru_seq "#{e|+|:#{@mru_seq},1}" ';'
    setw -Ft "$sid:$target" @mru "#{@mru_seq}")
  if [[ "$target" != "$orig" && -n "$orig_pane" ]]; then
    target_pane=$(tmux list-panes -t "$sid:$target" -F '#{?pane_active,#{pane_id},}' | grep .)
    land+=(';' set -g @last-pane "$orig_pane" ';' set -g @current-pane "$target_pane")
  fi
  tmux "${replay[@]}" ';' "${land[@]}" && landed=1
  exit 0
done
