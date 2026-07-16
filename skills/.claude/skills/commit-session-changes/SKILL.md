---
name: commit-session-changes
description: Commit only the files you changed this session, restoring any unrelated staged files byte-for-byte (partial stages included).
---

# Commit session changes

Commit only the changes made during *this* session, and leave the user's pre-staged work exactly as you found it — including files they had only *partially* staged.

Only one thing here needs judgment: **which files you changed this session.** Get that from the conversation (git can't tell your edits from the user's). The mechanics are the bundled `commit-session.sh` script — run it, don't reimplement it, so every run behaves the same.

## 1. Set aside, then stage your session files

Pass exactly the files you changed this session (quote paths with spaces):

```bash
~/.claude/skills/commit-session-changes/commit-session.sh stage path/you/changed another/file ...
```

It sets aside any unrelated staged hunks to a patch (NUL-safe, partial stages preserved, working tree untouched), then stages exactly your session files. If it prints `NOTHING_STAGED`, no session changes were staged — say so and stop (it already restored the index).

## 2. Hand off to conventional-commit

Invoke the `conventional-commit` skill to write the message and commit the staged set.

## 3. Restore the user's index

Run this **whether or not the commit happened** (e.g. cancelled, or a hook rejected it) so you never leave their index disturbed:

```bash
~/.claude/skills/commit-session-changes/commit-session.sh restore
```

Because the patch carries the exact staged hunks and the working tree was never touched, a partially-staged file returns partially staged — same staged/unstaged split as before.
