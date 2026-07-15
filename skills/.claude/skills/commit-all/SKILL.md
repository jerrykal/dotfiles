---
name: commit-all
description: Stage every change in the worktree, then commit it via conventional-commit.
disable-model-invocation: true
---

# Commit all

Stage the whole worktree, then hand the staged set to `conventional-commit`.

1. `git add -A` — stage every modified, new, and deleted file. If `git diff --cached --quiet` then passes (nothing staged), say there's nothing to commit and stop.
2. Invoke the `conventional-commit` skill to write the message and commit the staged set. **Approval is required:** you were invoked by name, so conventional-commit must present the full message via `AskUserQuestion` and commit only after the user picks the commit option — never commit before that.
