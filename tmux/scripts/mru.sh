# Sourced by the pickers: the @mru stamps that order windows by use.
#
# Each window carries a stamp from the server-wide @mru_seq counter, written
# by the session-window-changed hook in tmux.conf — tmux's own window stack
# can't order windows, since window_stack_index puts the current window at 0
# alongside every window never selected.

mru_us=$'\x1f'

# Hand a stamp to every window if any of them lacks one. Windows the hook
# never saw fall back to window_activity, which selecting a window bumps, so
# a picker's preview alone could reorder them; stamping freezes the order
# they are already in.
#
# Server-wide, not per session: one counter feeds every stamp, so renumbering
# a single session would lift its windows above windows used more recently
# elsewhere — which is exactly the comparison claude-picker makes.
mru_seed() {
  local row id chunk=() n=0 rows
  # Renumbering has to keep the order the windows are already in, so an
  # unstamped one is slotted into the existing stamps rather than sorted
  # against them: the window a session is sitting in goes just above that
  # session's newest stamp, since leaving it is what would have stamped it,
  # and one never visited goes below everything.
  mapfile -t rows < <(
    tmux list-windows -a \
      -F "#{session_id}${mru_us}#{window_id}${mru_us}#{@mru}${mru_us}#{window_activity}${mru_us}#{window_active}" |
      awk -F"$mru_us" -v us="$mru_us" '
        # A window linked into two sessions is listed once per session.
        !seen[$2]++ {
          n++; sid[n] = $1; id[n] = $2; mru[n] = $3; act[n] = $4; cur[n] = $5
          if ($3 != "" && $3 + 0 > top[$1]) top[$1] = $3 + 0
        }
        $3 == "" { stray = 1 }
        END {
          if (!stray) exit 0 # nothing to seed
          for (i = 1; i <= n; i++) {
            key = mru[i]
            if (key == "") key = cur[i] ? top[sid[i]] + 0.5 : 0
            print key us act[i] us cur[i] us id[i]
          }
        }' |
      sort -t"$mru_us" -k1,1n -k2,2n -k3,3n
  )
  ((${#rows[@]})) || return 0
  for row in "${rows[@]}"; do
    id=${row##*"$mru_us"}
    chunk+=(set -gF @mru_seq "#{e|+|:#{@mru_seq},1}" ';' setw -Ft "$id" @mru "#{@mru_seq}" ';')
    # tmux refuses a command past a limit this one would reach on a server
    # with a few hundred windows (it takes ~11 arguments per window, and
    # around 900 is already too many), so it goes out in batches.
    if ((++n % 50 == 0)); then
      tmux "${chunk[@]:0:${#chunk[@]} - 1}" || return 1
      chunk=()
    fi
  done
  ((${#chunk[@]})) && { tmux "${chunk[@]:0:${#chunk[@]} - 1}" || return 1; }
  return 0
}

# Fills $mru_stamp with the command-list fragment that makes $1 (any target
# resolving to a window) the most recently used. The pickers write it by hand
# because the hook is frozen while they run, and bump the counter inside the
# list so two of them can't hand out the same stamp.
mru_stamp_cmds() {
  mru_stamp=(set -gF @mru_seq "#{e|+|:#{@mru_seq},1}" ';' setw -Ft "$1" @mru "#{@mru_seq}")
}
