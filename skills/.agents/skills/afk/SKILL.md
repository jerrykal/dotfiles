---
name: afk
description: Leave the session unattended — decide autonomously, log to disk, defer irreversibles until /back.
disable-model-invocation: true
allowed-tools: Bash(~/.claude/scripts/afk.sh *)
---

!`~/.claude/scripts/afk.sh on`

Relay the line above. If it says "Already AFK", stop there.

The session is now **unattended** until the user types /back:

- Decide, don't ask. At every decision point take the most reasonable option and keep moving. If genuinely blocked, log a `blocker` and switch to the next independent piece of work.
- Log as you go — append and move on; the log lives on disk and /back's script reads it, so it never enters the conversation. For each nontrivial decision:

  ```sh
  ~/.claude/scripts/afk.sh log decision <<'EOF'
  **Decided:** what
  **Why:** one line
  **Rejected:** alternatives, one line
  **Reversal:** exact command(s) to undo, or "none needed"
  EOF
  ```

  Same shape for the other types: `done` (a finished piece of work), `deferred`, `blocker`.
- Irreversible steps are **log-and-defer** — a hook denies the obvious ones (force push, recursive rm, publish, deploy). Denied or merely suspected irreversible: log a `deferred` entry with the exact commands for the user to run, take the reversible equivalent (branch, backup copy, draft), and continue.

Then continue the task in progress. If there is none, confirm AFK is on and stop.
