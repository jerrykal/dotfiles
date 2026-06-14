# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

> **Keep `README.md` in sync.** It is the human-facing mirror of this file: the package list, the repo-path ↔ home-path table, the fold/`nofold` explanation, the `just` / `install.sh` command listings, and the Syncthing sync model all appear in both. Whenever a change touches any of those — adding/removing a package, adding or renaming a `just` recipe, changing the install flow, altering the sync setup — update the matching section of `README.md` in the **same** change. Treat a diff that updates one without the other as incomplete.

## What this repo is

Personal dotfiles, deployed by symlinking into `$HOME` with [GNU Stow](https://www.gnu.org/software/stow/). The repo is organized as **one Stow "package" per application** — each top-level dir (`nvim/`, `fish/`, `claude/`, `shell/`, `bin/`, …) contains a `$HOME`-shaped subtree that mirrors into `$HOME`.

That means a repo path is its home path **with the leading package dir stripped**:

- `nvim/.config/nvim/init.lua` → `~/.config/nvim/init.lua`
- `shell/.profile` → `~/.profile`
- `claude/.claude/settings.json` → `~/.claude/settings.json`
- `bin/.local/bin/pf` → `~/.local/bin/pf`

Stow always runs from the repo root, so its default target is the parent dir (`$HOME`). Most packages **fold** (the Stow default): `~/.config/atuin` is a single symlink to the package dir. The packages listed in `nofold` in the `justfile` — `claude`, `fish`, `nvim`, `tmux` — are instead stowed with `--no-folding`, which forces **file-level** symlinks so the directory stays a real dir. Those are the packages whose config dir also accumulates runtime/generated files (fisher plugins, TPM plugins, nvim `plugin/`/`spell/`, live `~/.claude` state); keeping the dir real prevents that state from leaking back into the repo. To move a package between the two behaviors, edit `nofold` and `just relink <pkg>`.

## Common commands

Day-to-day management is via [`just`](https://github.com/casey/just) (see `justfile`):

```bash
just                  # list recipes
just link             # symlink all packages into $HOME (just link nvim tmux for a subset)
just relink           # restow after renaming/removing tracked files
just unlink           # remove symlinks
just check            # dry-run — shows what would change (silent when up to date)
just prune            # remove dead symlinks pointing into this repo (just prune-check to dry-run)
just adopt            # pull existing $HOME files into the repo, then symlink back (migration aid)
just deps             # brew bundle install
just install          # deps + link (first-time setup)

./install.sh          # bootstrap: Homebrew + Brewfile + Claude Code, then `just link`
./install.sh --skip-deps   # link only (errors out if `just` is absent — no raw-stow fallback)
```

There is no test suite, lint config, or build step at the repo level — each tool's config lives under its own subtree and is exercised by running that tool.

## Architecture and conventions

### Adding a package / file

- **New file in an existing package:** drop it under the package's `$HOME`-shaped path (e.g. `nvim/.config/nvim/lua/...`) and run `just relink` so the new file gets its symlink.
- **New application:** create a top-level package dir with the home-shaped subtree (e.g. `foo/.config/foo/config`), then add `foo` to the `packages` list in the `justfile`. (`install.sh` doesn't list packages — it just calls `just link`.)

### git ignore

There is no `.stow-local-ignore` — in the per-package layout Stow reads ignore files from each *package's* root, not the repo root, and the packages contain only tracked config, so none is needed. `.gitignore` is just OS cruft plus a defense-in-depth list of runtime/generated artifacts (`fisher/`, tmux `plugins/`, nvim `plugin/`/`spell/`, `fish_variables`) that regenerate at their real `~` locations and must never be committed.

### Syncing across machines

The **laptop is the source of truth** and the only machine with a real `.git` — commit and push from there as usual. Remote machines receive the working tree via [Syncthing](https://syncthing.net) instead of `git pull`:

- `.stignore` (tracked) excludes `.git` from the sync, so Syncthing never touches git internals — no repo corruption, no `.sync-conflict-*` files inside `.git`. It also mirrors `.gitignore`'s runtime/generated artifacts so those stay per-machine.
- The laptop folder is **Send Only**; remotes are **Receive Only**. Edits flow laptop → remotes, matching the "edit on the laptop, sync everywhere" model. (Both machines must be online at the same time to sync — Syncthing has no async drop-box like GitHub.)
- `.stfolder`/`.stversions` are Syncthing's own runtime markers and are gitignored.

Bringing up a remote: install Syncthing (`brew "syncthing"` is in the Brewfile), pair it with the laptop, accept the shared `~/.dotfiles` folder as **Receive Only**, then run `./install.sh --skip-deps` (or `just link`) once to create the Stow symlinks — stow doesn't need git, so the absent `.git` is fine. `just sync-id` prints a machine's device ID for pairing. To bootstrap a machine the git way instead, clone the repo and run `./install.sh`.

### Shell entrypoints

The login chain is:

- `.bash_profile` / `.zprofile` → source `.profile` then `.bashrc` / `.zshrc`
- `.profile` — XDG basedirs, Homebrew shellenv, `$PATH`, `$EDITOR`, fzf colors
- `.bashrc` / `.zshrc` — interactive guard; if `fish` is available and `SKIP_FISH` is unset, `exec fish`

`SKIP_FISH=1` is how you stay in bash/zsh — the `bash`/`zsh` fish functions in `.config/fish/functions/` set it automatically when invoked from fish.

Anything that should run in *all* shells (env vars, PATH) belongs in `.profile`. Bash/zsh-only logic goes in `.bashrc`/`.zshrc`. Fish-only logic goes under `.config/fish/`.

### Fish (plugin manager + structure)

- Plugins listed in `.config/fish/fish_plugins`, managed by [fisher](https://github.com/jorgebucaran/fisher).
- `.config/fish/conf.d/__init__.fish` bootstraps fisher into `$__fish_config_dir/fisher` on first run, then sources every `$fisher_path/conf.d/*.fish`.
- `conf.d/abbr.fish` is the canonical place for abbreviations; `conf.d/alias.fish` for aliases. Functions go under `functions/` (one function per file, filename matches function name).

### Neovim

- Entrypoint: `.config/nvim/init.lua` → loads `config.options`, then on `User VeryLazy` loads `config.keymaps` and `config.autocmds`, then `config.lazy`.
- Plugin manager: [lazy.nvim](https://github.com/folke/lazy.nvim), bootstrapped in `lua/config/lazy.lua`. Plugin specs live in `lua/plugins/*.lua` and `lua/plugins/lang/*.lua` (auto-imported).
- VSCode-Neovim path: when `vim.g.vscode` is set, `init.lua` switches to the `config.vscode.*` namespace instead of `config.*`.

### Tmux

- `.config/tmux/tmux.conf` self-bootstraps TPM into `~/.tmux/plugins/tpm` on first run. Theme is split into `tmux.theme.conf`.
- Prefix is `C-Space` (not `C-b`).

### Claude Code

`.claude/settings.json` is the user-level Claude config. The interesting bits:

- `extraKnownMarketplaces.local` registers `./.claude/plugins/local` as a plugin marketplace, defined by `.claude/plugins/local/.claude-plugin/marketplace.json`. Two local plugins are published from there: `ty-lsp` (Astral ty Python LSP) and `ruff-lsp` — each is just a `.claude-plugin/plugin.json` + `.lsp.json`.
- `enabledPlugins` toggles those local plugins plus several from `claude-plugins-official`.
- `.claude/skills/` holds user-level skills (e.g. `answer/SKILL.md`).

When adding a new local plugin, register it in `marketplace.json` *and* enable it in `settings.json`'s `enabledPlugins`.

Because `claude` is `--no-folding`, a skill installed into `~/.claude/skills/<name>/` lands as real files with no link back to the repo. Run `just new-skills` to list untracked skills, then `just adopt-skill <name>` to move one into `claude/.claude/skills/` and relink it (Stow then symlinks the files back into `~/.claude`). Commit from the laptop; Syncthing carries it to remotes. Plugin-delivered skills (under `~/.claude/plugins/`) are managed via `enabledPlugins` instead, not adopted.

### Local scripts (`.local/bin`)

Custom helpers (`pf`, `tmux-sesh`) live in the `bin/` package (`bin/.local/bin/`). `$PATH` includes `~/.local/bin` via `.profile`. Add a new script under `bin/.local/bin/` and run `just relink`. (Machine-specific absolute symlinks that other tools drop into `~/.local/bin`, e.g. `claude`/`codex`, are not tracked — Stow ignores absolute symlinks anyway.)
