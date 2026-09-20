#!/usr/bin/env bash
# All three Claude Code notification hooks behind one entry point.
#
#   notify-hook.sh notification|stop|failure     # hook JSON on stdin
#
# Hands Claude Code the OSC 777 sequence as `terminalSequence` and lets it do
# the writing, rather than shelling out to `notify`: a hook's stdout is
# captured by its caller instead of being wired to the terminal, so a sequence
# printed from here would never reach the emulator. These hooks must stay
# synchronous — Claude discards the output of an `async` hook, terminalSequence
# included.
#
# The allowlist takes a list of sequences and accepts a bare BEL among them, so
# one rides along after the OSC to make tmux flag the window (monitor-bell,
# window-status-bell-style) the way writing to the pane's pty used to.
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
  # Fail open: if jq is missing or the fields aren't there, notify as before.
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
  body=$(jq -r '.message // empty' <<<"$input" 2>/dev/null)
  body=${body:-Notification}
  ;;
esac

# Same payload rules as bin/notify: the sequence is ;-delimited and ends at
# BEL, so a control byte truncates it, and Ghostty reads everything past the
# title's ';' as body — only the title needs its semicolons collapsed.
scrub() { local s=${1//[$'\t\r\n']/ }; printf '%s' "${s//[[:cntrl:]]/}"; }

# A second-resolution timestamp keeps back-to-back notifications distinct;
# emulators coalesce ones whose title and body match exactly.
body="$body · $(date +%H:%M:%S)"

seq=$(printf '\e]777;notify;%s;%s\a\a' "$(scrub "${title//;/,}")" "$(scrub "$body")")

# Without jq there is no way to emit the JSON; fall back to the shared
# notifier, which routes itself.
command -v jq >/dev/null 2>&1 || exec "$HOME/.local/bin/notify" "$title" "$body"
jq -cn --arg seq "$seq" '{terminalSequence: $seq}'
