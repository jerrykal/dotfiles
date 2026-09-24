#!/usr/bin/env bash
# All three Claude Code notification hooks behind one entry point.
#
#   notify-hook.sh notification|stop|failure     # hook JSON on stdin
#
# Inside tmux, hand off to the shared `notify`, which picks one attached client,
# stays silent when a focused client already sits on this pane, tags the title
# with the session and window, and rings the pane's bell.
#
# Outside tmux, return the OSC 777 sequence as `terminalSequence` and let Claude
# Code write it: a hook's stdout is captured by its caller instead of being
# wired to the terminal. These hooks must stay synchronous — Claude discards the
# output of an `async` hook, terminalSequence included.
set -u

mode=${1:-notification}
input=$(cat)
title='Claude Code'

case $mode in
stop)
  # Headless `claude -p` runs (commit drafts, scripted children) fire this hook
  # too and each would ping "Task complete"; they set ENTRYPOINT to sdk-cli
  # (interactive sessions use "cli"), so skip those outright.
  [ "${CLAUDE_CODE_ENTRYPOINT:-}" = "sdk-cli" ] && exit 0

  # Only notify when the session is truly done, not on every turn boundary of a
  # self-resuming session (scheduled wakeups from /loop-style monitoring,
  # running background tasks). The Stop hook fires at the end of EVERY turn, so
  # without this filter each loop iteration pings "Task complete".
  #
  # Signals (Stop hook stdin JSON, Claude Code >= 2.1.145):
  #   session_crons    — pending scheduled wakeups; non-empty means auto-resume
  #   background_tasks — anything not "completed" will re-invoke the session
  # Fail open: if the fields aren't there, notify.
  pending=$(jq -r '
    ((.session_crons // []) | length) +
    ([(.background_tasks // [])[] | select(.status != "completed")] | length)
  ' <<<"$input" 2>/dev/null)
  [ "${pending:-0}" -gt 0 ] 2>/dev/null && exit 0

  body='Task complete'
  ;;
failure)
  body='Task failed'
  ;;
*)
  # Claude drops a terminalSequence over 4096 bytes whole, and .message has no
  # length bound, so cap it.
  body=$(jq -r '.message // empty | .[:200]' <<<"$input" 2>/dev/null)
  body=${body:-Notification}
  ;;
esac

[ -n "${TMUX:-}" ] && exec "$HOME/.local/bin/notify" "$title" "$body"

# Same payload rules as bin/notify: the sequence ends at BEL, so a control byte
# would truncate it. The title is a constant, so only the body needs scrubbing.
scrub() { local s=${1//[$'\t\r\n']/ }; printf '%s' "${s//[[:cntrl:]]/}"; }

# A second-resolution timestamp keeps back-to-back notifications distinct;
# emulators coalesce ones whose title and body match exactly.
body="$body · $(date +%H:%M:%S)"

jq -cn --arg seq "$(printf '\e]777;notify;%s;%s\a' "$title" "$(scrub "$body")")" \
  '{terminalSequence: $seq}'
