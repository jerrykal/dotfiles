---
name: commit-staged
description: Commit exactly what's already staged via conventional-commit, touching nothing else.
disable-model-invocation: true
---

# Commit staged

Commit the current index as-is.

If `git diff --cached --quiet` (nothing staged), say so and stop.

Otherwise invoke the `conventional-commit` skill to write the message, get approval, and commit. Commit the staged changes only — do not `git add`, restage, or otherwise touch the index; the user chose what's in it.
