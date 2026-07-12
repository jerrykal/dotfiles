#!/usr/bin/env bash
# Stop-hook wrapper around notify.sh: only notify when the session is truly
# done, not on every turn boundary of a self-resuming session (scheduled
# wakeups from /loop-style monitoring, running background tasks). The Stop
# hook fires at the end of EVERY turn, so without this filter each loop
# iteration pings "Task complete".
#
# Signals (Stop hook stdin JSON, Claude Code >= 2.1.145):
#   session_crons    — pending scheduled wakeups; non-empty means auto-resume
#   background_tasks — anything not "completed" will re-invoke the session
# Fail open: if jq is missing or the fields aren't there, notify as before.

input=$(cat)

pending=$(jq -r '
  ((.session_crons // []) | length) +
  ([(.background_tasks // [])[] | select(.status != "completed")] | length)
' <<<"$input" 2>/dev/null)

[ "${pending:-0}" -gt 0 ] 2>/dev/null && exit 0

TITLE='Claude Code' BODY='Task complete' exec "$(dirname "$0")/notify.sh"
