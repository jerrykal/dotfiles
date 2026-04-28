# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Personal dotfiles, deployed by symlinking the repo's contents into `$HOME` with [GNU Stow](https://www.gnu.org/software/stow/). The repository root is treated as a single Stow "package" — every top-level file/dir (except those listed in `.stow-local-ignore`) is mirrored into `$HOME` at the corresponding path.

That means: paths in the repo are paths on disk. `/.config/nvim/init.lua` becomes `~/.config/nvim/init.lua`, `/.profile` becomes `~/.profile`, etc.

## Common commands

```bash
./install.sh              # Install Homebrew + Brewfile packages, then run `stow -v .`
./install.sh --skip-deps  # Re-run stow only (skip Homebrew install/update)
stow -v .                 # Refresh symlinks after adding/removing tracked files
stow -Dv .                # Unstow (remove symlinks) — rarely needed
brew bundle install       # Sync packages from Brewfile
brew bundle cleanup       # Show packages installed but not in Brewfile
```

There is no test suite, lint config, or build step at the repo level — each tool's config lives under its own subtree and is exercised by running that tool.

## Architecture and conventions

### Stow ignore vs git ignore

Two ignore files do different jobs and both must be kept consistent:

- `.stow-local-ignore` — what `stow` skips when symlinking. Things that exist in the repo but should NOT appear in `$HOME` (e.g. `.git`, `README.md`, `Brewfile`, `install.sh`).
- `.gitignore` — what git tracks. Used here as an *allow-list* for `.local/bin/` and `.claude/plugins/`: everything is ignored by default and only specific files are un-ignored with `!`. When adding a new tracked script under `.local/bin/`, add an explicit `!.local/bin/<name>` line.

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

### Local scripts (`.local/bin`)

Custom helpers (`pf`, `tmux-opencode`, `tmux-sesh`, `tmux-pi`) live here. `$PATH` includes `~/.local/bin` via `.profile`. Note the allow-list pattern in `.gitignore` — new scripts must be explicitly un-ignored to be tracked.
