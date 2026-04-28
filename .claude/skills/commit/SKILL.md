---
name: commit
description: Analyze currently staged git changes and craft a Conventional Commits-formatted message, then create the commit. Use whenever the user invokes /commit, asks to "commit the staged changes", "write a commit message", "make a conventional commit", or otherwise wants help turning what's already in the index into a well-structured commit. Trigger even when the user doesn't say the words "conventional commits" — if they're asking to commit staged work, this is the skill.
---

# /commit

Turn the user's currently staged changes into a single well-structured commit that follows the [Conventional Commits](https://www.conventionalcommits.org/) specification.

The user has already decided *what* to commit by staging it. Your job is to read that diff carefully, write a message that will still make sense to someone bisecting a regression six months from now, and create the commit.

## Workflow

### 1. Inspect the working tree

Run these in parallel — you need all three before you can write a good message:

- `git status` — see what's staged vs. unstaged vs. untracked
- `git diff --cached` — read the staged changes (this is the source of truth)
- `git log -10 --pretty=format:'%h %s'` — match the repo's existing style (casing, scope vocabulary, whether bodies are common, etc.)

If `git diff --cached` is empty, stop and tell the user there's nothing staged. Do **not** run `git add` to "fix" it — staging is the user's call, and silently widening the commit's scope is the kind of thing that loses work.

### 2. Classify the change

Pick the type that best describes the *intent* of the change:

| Type       | Use for |
|------------|---------|
| `feat`     | New user-visible capability |
| `fix`      | Bug fix |
| `docs`     | Documentation only |
| `style`    | Formatting, whitespace, no behavior change |
| `refactor` | Internal restructuring, no behavior change |
| `perf`     | Performance improvement |
| `test`     | Adding or fixing tests |
| `build`    | Build system, dependencies (lockfiles, package.json, Brewfile, etc.) |
| `ci`       | CI configuration (workflows, pipelines) |
| `chore`    | Tooling/repo housekeeping that doesn't fit elsewhere |
| `revert`   | Reverts a previous commit |

If the diff genuinely spans multiple types (e.g., a `feat` mixed with an unrelated `fix`), surface this to the user before committing — that's usually a signal the commit should be split. Don't silently pick the "biggest" type and bury the rest.

### 3. Pick a scope (optional)

A scope is a short noun in parentheses naming the area of the codebase being changed: `feat(auth): ...`, `fix(parser): ...`. Useful when the repo has clearly delineated areas; skip when there isn't an obvious one.

Look at recent commits (`git log`) to see what scopes the repo already uses and **match the existing casing and vocabulary**. If the project doesn't use scopes, don't introduce them.

### 4. Write the subject line

Format: `<type>(<scope>): <subject>` or `<type>: <subject>`.

- **Imperative mood**: "add", "fix", "remove" — not "added", "fixes", "removing". Read it as completing the sentence "If applied, this commit will ___".
- **No trailing period.**
- **Casing**: lowercase the first letter of the subject by default, but match repo style if existing commits show otherwise.
- **Length**: aim for ≤ 72 chars. If you can't say it in 72, the commit might be doing too much.
- **Breaking change**: append `!` before the colon — `feat(api)!: drop legacy auth`.

### 5. Decide whether a body is needed

A body is for *why*, not *what*. The diff shows what; the body tells future-you why it was worth changing.

Add a body when:

- The motivation isn't obvious from the diff (perf wins, prep for a future change, working around a third-party bug)
- It's a non-trivial fix and you want to capture what was broken and why this fixes it
- There's a non-obvious tradeoff or decision a reviewer might second-guess

Skip the body when the subject already says everything that matters (typo fixes, dependency bumps, simple renames). A body that just restates the subject is noise.

When you do write one:

- Blank line between subject and body
- Wrap at ~72 chars
- Plain prose, not a bulleted list of every file touched

### 6. Footers (when applicable)

- `BREAKING CHANGE: <description>` — required for breaking changes; explain the migration path
- `Closes #123`, `Refs #456` — issue references
- `Co-authored-by: Name <email>` — only if the user asks or has set this up

### 7. Create the commit

Show the proposed message to the user first, then commit using a HEREDOC so multi-line messages format correctly:

```bash
git commit -m "$(cat <<'EOF'
feat(auth): add JWT refresh token rotation

Previously tokens were single-use; this allows clients to refresh
without re-prompting credentials. Closes #142.
EOF
)"
```

Then run `git status` to confirm.

If a pre-commit hook fails: the commit did **not** happen. Fix the underlying issue, re-stage if needed, and create a **new** commit. Do not `--amend` (that would modify a *different*, previous commit) and do not retry with `--no-verify`.

## Hard rules

These exist to avoid losing the user's work or surprising them:

- **Never run `git add`.** Work only with what's already staged. If nothing is staged, stop and say so.
- **Never use `--no-verify`, `--no-gpg-sign`, or `-c commit.gpgsign=false`** unless the user explicitly asks. Hooks exist for a reason; if one fails, fix the cause.
- **Never `--amend`** unless the user explicitly asks. Amending rewrites a previous commit and can quietly destroy work.
- **Never include "Generated with Claude" or `Co-authored-by: Claude` trailers** unless the user has set this up themselves.
- **Don't push.** Pushing is the user's call and affects shared state.

## Examples

**Trivial change → no body:**

```
docs: fix typo in installation steps
```

**Bug fix where *why* isn't obvious from the diff:**

```
fix(parser): handle empty input without panicking

The slicing path assumed at least one byte; an empty payload from
the upstream queue tripped an index-out-of-bounds. Returns Err
early instead of indexing into the buffer.
```

**Refactor that needs context (otherwise reviewers will ask "why now?"):**

```
refactor(storage): extract retry logic into shared helper

Three call sites had drifted out of sync on backoff parameters.
Consolidating into one helper so the next timeout tuning is a
single-file change.
```

**Breaking change:**

```
feat(api)!: require auth header on /metrics endpoint

BREAKING CHANGE: clients calling /metrics without an Authorization
header now receive 401. Internal tooling has been updated; external
consumers must add a bearer token before deploying.
```

**Build/dependency bump:**

```
build(deps): bump axios from 1.6.2 to 1.7.0
```

## Why these conventions matter

Conventional Commits aren't ceremony. The structured prefix makes `git log` greppable, lets release tooling auto-generate changelogs, and tells a reviewer at a glance whether a commit changes behavior, fixes a bug, or just shuffles code. The body — when it exists — is for the future reader bisecting a regression who needs to know *why* a line changed, not *what* changed. The diff already shows the what.
