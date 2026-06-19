# Dotfiles

My personal dotfiles for macOS (and Linux), deployed by symlinking into `$HOME`
with [GNU Stow](https://www.gnu.org/software/stow/) and managed with
[`just`](https://github.com/casey/just).

## Layout

The repo is organized as **one Stow "package" per application**. Each top-level
dir is a `$HOME`-shaped subtree that mirrors into `$HOME` — a repo path is its
home path with the leading package dir stripped:

| Repo path | Home path |
| --- | --- |
| `nvim/.config/nvim/init.lua` | `~/.config/nvim/init.lua` |
| `shell/.profile` | `~/.profile` |
| `claude/.claude/settings.json` | `~/.claude/settings.json` |
| `bin/.local/bin/pf` | `~/.local/bin/pf` |

Packages: `atuin` `bat` `bin` `claude` `eza` `fish` `git` `lazygit` `mise`
`nvim` `ruff` `sesh` `shell` `tmux`.

Most packages **fold** (the Stow default — the whole dir becomes one symlink).
The packages in `nofold` (`claude`, `fish`, `nvim`, `tmux`) are stowed with
`--no-folding` so the dir stays real and the runtime/generated files those tools
drop in (fisher/TPM plugins, nvim `plugin/`/`spell/`, live `~/.claude` state)
never leak back into the repo.

## Installation

```bash
./install.sh              # Homebrew + Brewfile + Claude Code, then `just link`
./install.sh --skip-deps  # link only (deps assumed present)
```

## Common commands

Day-to-day management is via `just` (see the `justfile`):

```bash
just            # list recipes
just link       # symlink all packages into $HOME (e.g. `just link nvim tmux` for a subset)
just relink     # restow after renaming/removing tracked files
just unlink     # remove symlinks
just check      # dry-run — show what would change
just prune      # remove dead symlinks pointing into this repo
just deps       # brew bundle install
just install    # deps + link
```

There is no repo-level test, lint, or build step — each tool's config is
exercised by running that tool.

## Syncing across machines

The **laptop is the source of truth** by convention — it's the only machine with
a real `.git`, so commit and push from there. Working trees sync via
[Syncthing](https://syncthing.net) with every machine sharing the folder as
*Send & Receive* (Syncthing's standard, bidirectional [folder
type](https://docs.syncthing.net/users/foldertypes.html) — an edit on a remote
flows back to the laptop too), and `.stignore` excluding `.git` and runtime
artifacts so a `*.sync-conflict-*` can never corrupt git. On a
remote, run `./install.sh --skip-deps` once to create the Stow symlinks —
Stow doesn't need git, so the absent `.git` is fine. `just sync-id` prints a
machine's Syncthing device ID for pairing.
