#!/usr/bin/env bash
# Helper for the commit-session-changes skill. The agent supplies the one thing
# that needs judgment — the list of files it changed this session — and this
# script does the mechanical set-aside / restore so every run behaves the same.
#
#   commit-session.sh stage <file>...   # set aside unrelated staged hunks, stage session files
#   commit-session.sh restore           # put the user's staged hunks back
#   commit-session.sh test              # self-check the byte-for-byte round-trip
set -euo pipefail

patch_path(){ echo "$(git rev-parse --git-dir)/commit-session.patch"; }

# Set aside everything staged that ISN'T a session file (saved verbatim to a
# binary patch, working tree untouched), then stage exactly the session files.
cmd_stage(){
  [ "$#" -gt 0 ] || { echo "usage: commit-session.sh stage <file>..." >&2; exit 2; }
  local session=( "$@" )
  is_session(){ local f; for f in "${session[@]}"; do [ "$f" = "$1" ] && return 0; done; return 1; }

  # Unrelated staged files = staged minus session. NUL-safe, so spaces survive.
  local unrelated=() f
  while IFS= read -r -d '' f; do is_session "$f" || unrelated+=( "$f" ); done < <(git diff --cached --name-only -z)

  local patch; patch="$(patch_path)"
  if [ "${#unrelated[@]}" -gt 0 ]; then
    git diff --cached --binary -- "${unrelated[@]}" > "$patch"   # save the user's staged hunks verbatim
    git restore --staged -- "${unrelated[@]}"                    # set them aside (working tree untouched)
  fi
  git add -- "${session[@]}"                                     # stage exactly the session changes

  if git diff --cached --quiet; then
    cmd_restore                                                  # nothing to commit — don't leave the index disturbed
    echo "NOTHING_STAGED: no session changes were staged"
    exit 0
  fi
}

# Re-apply the saved staged hunks. Run whether or not the commit happened.
cmd_restore(){
  local patch; patch="$(patch_path)"
  if [ -s "$patch" ]; then
    git apply --cached "$patch"
    rm -f "$patch"
  fi
}

# Round-trip self-check: a divergent stage (index=A, worktree=B) must survive
# the stage -> commit -> restore cycle with the same staged/unstaged split.
cmd_test(){
  local tmp rc=0; tmp="$(mktemp -d)"
  ( cd "$tmp"
    git init -q; git config user.email t@t; git config user.name t
    printf 'base\n' > unrelated.txt; printf 'base\n' > session.txt
    git add .; git commit -qm init

    printf 'staged-A\n' > unrelated.txt; git add unrelated.txt   # user stages version A...
    printf 'worktree-B\n' > unrelated.txt                        # ...then diverges the working tree
    before_staged="$(git diff --cached)"; before_tree="$(git diff)"

    printf 'session-edit\n' > session.txt                        # the agent's session change
    cmd_stage session.txt >/dev/null
    git diff --cached --quiet session.txt && { echo "FAIL: session not staged"; exit 1; }
    git commit -qm session                                       # conventional-commit's job, in real life
    cmd_restore

    [ "$(git diff --cached)" = "$before_staged" ] || { echo "FAIL: staged index not restored"; exit 1; }
    [ "$(git diff)" = "$before_tree" ]             || { echo "FAIL: working tree changed"; exit 1; }
    echo "PASS"
  ) || rc=$?
  rm -rf "$tmp"
  return "$rc"
}

case "${1:-}" in
  stage)   shift; cmd_stage "$@" ;;
  restore) cmd_restore ;;
  test)    cmd_test ;;
  *) echo "usage: commit-session.sh {stage <file>... | restore | test}" >&2; exit 2 ;;
esac
