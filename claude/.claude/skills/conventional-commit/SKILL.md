---
name: conventional-commit
description: Create a Conventional Commits-formatted git commit. Use whenever you make a commit — whether the user asked for one or you're committing work you did as part of a task.
user-invocable: false
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

Inspect the diff you're about to commit and the recent `git log`, then commit with a HEREDOC so multi-line messages survive:

```bash
git commit -m "$(cat <<'EOF'
fix(parser): handle empty input without panicking

The slicing path assumed at least one byte; an empty upstream payload
tripped an index-out-of-bounds. Returns Err early instead.
EOF
)"
```

Show the proposed message, then commit and run `git status` to confirm. Reach for `AskUserQuestion` only when something's genuinely ambiguous — the diff should be split, the type or scope is a real toss-up — not as a routine confirmation gate.

## Hard rules

These prevent losing or rewriting work you didn't mean to:

- **No `--amend`** unless asked — it rewrites a previous commit.
- **No `--no-verify`, `--no-gpg-sign`, or `-c commit.gpgsign=false`** unless asked. If a hook fails the commit didn't happen: fix the cause, re-stage, commit anew — don't bypass.
- **No "Generated with Claude" / `Co-authored-by: Claude` trailers** unless the user set that up.
- **Don't push.** That's the user's call.
