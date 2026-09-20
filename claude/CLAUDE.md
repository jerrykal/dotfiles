- Comment only where the why is non-obvious.
- fish is my interactive shell (your Bash tool runs sh).
- mise manages CLI runtimes and project environments: pin tools with `mise use`, run through `mise exec` / `mise run`, env vars in `mise.toml`'s `[env]`, secrets in `mise.local.toml` (gitignored globally).
- Worktrees run on worktrunk (`wt`): enter and leave one with EnterWorktree/ExitWorktree, which the plugin's hooks route through `wt switch --create` / `wt remove`; reach for `wt` itself for everything else (list, merge, step).
- Address a tmux object by its id — `$0` session, `@0` window, `%0` pane — which stays valid across moves, renames and re-indexing, unlike `session:window.pane`.
- When porting code from another local repo, write commit messages, PR text and docstrings in the target repo's own terms — its readers cannot see the source repo, so cite it only where the target already does.

@~/.claude/CLAUDE.local.md
