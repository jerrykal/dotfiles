---
name: commit-staged
description: Commit exactly what's already staged via conventional-commit, touching nothing else.
disable-model-invocation: true
---

# Commit staged

Commit the current index as-is.

If `git diff --cached --quiet` (nothing staged), say so and stop.

Otherwise invoke the `conventional-commit` skill to write the message and commit. **Approval is required:** you were invoked by name, so conventional-commit must present the full message via `AskUserQuestion` and commit only after the user picks the commit option — never commit before that. Commit the staged changes only — do not `git add`, restage, or otherwise touch the index; the user chose what's in it.
