---
name: conventional-commit
description: Create a Conventional Commits-formatted git commit. Use whenever you make a commit — whether the user asked for one or you're committing work you did as part of a task.
user-invocable: false
model: sonnet
effort: high
---

# Conventional commit

Create a single well-structured commit following [Conventional Commits](https://www.conventionalcommits.org/). Write the message so it still makes sense to someone bisecting a regression six months from now.

## What to commit

Commit what the user named; if they didn't say, stage the changes relevant to *this* change yourself. If the diff spans unrelated concerns (a `feat` plus an unrelated `fix`), it usually wants to be more than one commit — split it, or surface the choice via `AskUserQuestion`.

## Writing the message

Format: `<type>(<scope>): <subject>`, where type is one of `feat fix docs style refactor perf test build ci chore revert` and scope is optional.

- **Match the repo.** Read `git log` for the scopes, casing, and vocabulary already in use and mirror them. Don't introduce scopes a project doesn't use.
- **Subject**: imperative mood ("add", not "added"), no trailing period, ≤72 chars. Append `!` before the colon for a breaking change.
- **Body** (blank line, then ~72-char wrapped prose): only when *why* isn't obvious from the diff — motivation, a non-obvious tradeoff, what a fix actually repaired. The diff already shows *what*; a body that restates it is noise. Skip it for typos, bumps, and simple renames.
- **Footers** when they apply: `BREAKING CHANGE: <migration path>`, `Closes #123`.

## Creating it

Run in order; each ✓ gate holds before moving on:

1. **Stage** what belongs in this commit (see *What to commit*). ✓ `git diff --cached` shows exactly this change, nothing unrelated.
2. **Inspect** the staged diff and `git log -20`. ✓ the message mirrors the scopes, casing, and vocabulary already in the log.
3. **Draft** the message (see *Writing the message*).
4. **Approve**: present the full proposed message through `AskUserQuestion` (options like "Commit as proposed" / "Edit" / "Cancel", full message in an option's `description` so the user sees exactly what they approve). ✓ the user chose to commit.
5. **Commit** with a HEREDOC (below) so multi-line messages survive, then **confirm** with `git status`.

```bash
git commit -m "$(cat <<'EOF'
fix(parser): handle empty input without panicking

The slicing path assumed at least one byte; an empty upstream payload
tripped an index-out-of-bounds. Returns Err early instead.
EOF
)"
```

## Hard rules

These prevent losing or rewriting work you didn't mean to:

- **No `--amend`** unless asked — it rewrites a previous commit.
- **No `--no-verify`, `--no-gpg-sign`, or `-c commit.gpgsign=false`** unless asked. If a hook fails the commit didn't happen: fix the cause, re-stage, commit anew — don't bypass.
- **No "Generated with Claude" / `Co-authored-by: Claude` trailers** unless the user set that up.
- **Don't push.** That's the user's call.
