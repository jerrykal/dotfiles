# CLAUDE.md

> **Keep `README.md` in sync** — it's the human-facing mirror of this file. When a change alters the structure, commands, or sync model, update both in the same diff.

## What this repo is

Personal dotfiles, deployed by symlinking into `$HOME` with [GNU Stow](https://www.gnu.org/software/stow/). Organized as **one Stow package per application** — each top-level dir (`nvim/`, `fish/`, …) holds a `$HOME`-shaped subtree. A repo path is its home path with the leading package dir stripped: `nvim/.config/nvim/init.lua` → `~/.config/nvim/init.lua`.

Stow runs from the repo root, so its target is the parent (`$HOME`). Most packages **fold** (one symlink for the whole dir). The packages in `nofold` (see `justfile`) use `--no-folding` so the dir stays real — those accumulate runtime/generated files (fisher/TPM plugins, nvim `plugin/`/`spell/`, live `~/.claude` state) that must not leak back into the repo. To switch a package's behavior, edit `nofold` and `just relink <pkg>`.

## Commands

`just` lists all recipes (`link`, `relink`, `unlink`, `check`, `prune`, `adopt`, `deps`, `install`, `sync-id`) — `justfile` documents each. `./install.sh` bootstraps a fresh machine (Homebrew + Brewfile + Claude Code, then `just link`); `--skip-deps` links only. No test/lint/build at the repo level.

## Conventions

### Adding a package / file
- **New file in an existing package:** drop it at its `$HOME`-shaped path and `just relink`.
- **New application:** create the package dir, then add it to `packages` in the `justfile`.

### git / stow ignore
No `.stow-local-ignore` — in the per-package layout Stow reads ignores from each *package's* root, and packages hold only tracked config. `.gitignore` is OS cruft plus runtime/generated artifacts that regenerate at their real `~` locations and must never be committed.

### Syncing across machines
The **laptop is the source of truth** — only machine with a real `.git`; commit/push there. Remotes get the working tree via [Syncthing](https://syncthing.net) as **Send & Receive** (bidirectional). The tracked `.stignore` keeps `.git` out of the sync (so a `*.sync-conflict-*` can never corrupt git internals) and mirrors `.gitignore`'s runtime artifacts. Bring up a remote: pair Syncthing (`just sync-id` for the device ID), accept the shared `~/.dotfiles`, then `just link` (stow doesn't need git). Both machines must be online at once — no async drop-box.
