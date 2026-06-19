---
name: commit-session-changes
description: Commit only the files you changed this session, restoring any unrelated staged files byte-for-byte (partial stages included).
disable-model-invocation: true
---

# Commit session changes

Commit only the changes made during *this* session, and leave the user's pre-staged work exactly as you found it — including files they had only *partially* staged.

Only one thing here needs judgment: **which files you changed this session.** Get that from the conversation (git can't tell your edits from the user's). Everything else is the two command blocks below — run them verbatim so every run behaves the same.

## 1. Set aside, then stage your session files

```bash
session=( path/you/changed ... )   # the ONLY thing you fill in

# Unrelated staged files = staged minus session. Computed, not eyeballed.
# NUL-safe + array-quoted throughout, so paths with spaces survive.
is_session(){ local f; for f in "${session[@]}"; do [ "$f" = "$1" ] && return 0; done; return 1; }
unrelated=()
while IFS= read -r -d '' f; do is_session "$f" || unrelated+=( "$f" ); done < <(git diff --cached --name-only -z)
patch="$(git rev-parse --git-dir)/commit-session.patch"

if [ "${#unrelated[@]}" -gt 0 ]; then
  git diff --cached --binary -- "${unrelated[@]}" > "$patch"   # save the user's staged hunks verbatim
  git restore --staged -- "${unrelated[@]}"                    # set them aside (working tree untouched)
fi
git add -- "${session[@]}"                                     # stage exactly your session changes
```

If `git diff --cached --quiet` now passes (no session changes were staged), say so and stop.

## 2. Hand off to conventional-commit

Invoke the `conventional-commit` skill to write the message, get approval, and commit the staged set. Don't `git add` anything beyond what step 1 staged.

## 3. Restore the user's index

Run this **whether or not the commit happened** (e.g. cancelled, or a hook rejected it) so you never leave their index disturbed:

```bash
patch="$(git rev-parse --git-dir)/commit-session.patch"
[ -s "$patch" ] && git apply --cached "$patch" && rm -f "$patch"
```

Because the patch carries the exact staged hunks and the working tree was never touched, a partially-staged file returns partially staged — same staged/unstaged split as before.
