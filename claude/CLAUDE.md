- Comment only where the why is non-obvious.
- fish is my interactive shell (your Bash tool runs sh).
- mise manages CLI runtimes and project environments: pin tools with `mise use`, run through `mise exec` / `mise run`, env vars in `mise.toml`'s `[env]`, secrets in `mise.local.toml` (gitignored globally).
- Reach for worktrunk (`wt`) over `git worktree` whenever a task needs a worktree.
- When porting code from another local repo, write commit messages, PR text and docstrings in the target repo's own terms — its readers cannot see the source repo, so cite it only where the target already does.

@~/.claude/CLAUDE.local.md
