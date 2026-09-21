#!/usr/bin/env bash
# guard-tmux.sh — PreToolUse guard that refuses `tmux kill-server`.
#
#   guard-tmux.sh        # hook JSON on stdin
#
# kill-server takes down every session on a socket, and an agent that believes
# it is talking to a throwaway server has no way to tell from the exit status
# that it just closed the one holding the user's work — which is how this guard
# came to exist.
#
# A deny permission rule only prefix-matches, so it never sees `tmux -L sock
# kill-server` or a kill-server buried in a compound command; matching the whole
# command line here does. Only option-ish tokens are allowed between `tmux` and
# the subcommand, so a pipeline that merely greps for the word still runs —
# quoting it as a literal argument does not, which is the side to err on.
set -u

# Without jq the raw hook JSON stands in for the command: the escaping differs
# but the words still read through it, so the guard holds rather than opening.
input=$(cat)
command=$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null) || command=$input
[ -n "$command" ] || command=$input

kill_server='(^|[^[:alnum:]_.-])tmux[[:space:]]+([^;&|]*[[:space:]])?kill-server([[:space:];&|)]|$)'
if [[ $command =~ $kill_server ]]; then
  jq -nc '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason:
        "tmux kill-server is blocked: it destroys every session on that socket, including the one this session runs in. Kill only what you created — `tmux -L <your-socket> kill-session -t <your-session>`."
    }
  }'
fi
exit 0
