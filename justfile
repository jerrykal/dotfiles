# Dotfiles — managed with GNU Stow. Run `just` to see recipes.
#
# Each top-level dir is a Stow "package" whose tree mirrors into $HOME.
# Stow runs from this dir, so its default target is the parent — exactly $HOME.

# All packages, in link order. Add new package dirs here.
packages := "atuin bat bin claude eza fish git lazygit mise nvim ruff sesh shell tmux"

# Packages whose config dir also accumulates runtime/generated files — fisher
# plugins, TPM plugins, nvim plugin/spell/, live ~/.claude state. These are
# stowed with --no-folding so the directory stays REAL and those files never
# land in the repo. Everything else folds normally (one symlink per package).
nofold := "claude fish nvim tmux"

_default:
    @just --list --unsorted

# Symlink packages into $HOME (default: all). e.g. `just link nvim tmux`
link *pkgs=packages:
    @just _apply "" "{{pkgs}}"

# Re-link after renaming/removing tracked files (default: all)
relink *pkgs=packages:
    @just _apply "--restow" "{{pkgs}}"

# Remove symlinks for packages (default: all)
unlink *pkgs=packages:
    @just _apply "--delete" "{{pkgs}}"

# Dry-run — show what would change without touching anything (default: all)
check *pkgs=packages:
    @just _apply "--no" "{{pkgs}}"

# Adopt existing $HOME files into the repo, then symlink back (migration aid)
adopt *pkgs=packages:
    @just _apply "--adopt" "{{pkgs}}"

# Print this machine's Syncthing device ID (for pairing remotes)
sync-id:
    @syncthing device-id 2>/dev/null || echo "syncthing not installed/configured yet"

# Sync Homebrew packages from Brewfile
deps:
    brew bundle install

# First-time setup: Homebrew + Brewfile, then link everything
install: deps link

# internal: run `stow <action>` over each package, adding --no-folding for the
# packages listed in `nofold`. Folding (the stow default) is used otherwise.
_apply action pkgs:
    #!/usr/bin/env bash
    set -euo pipefail
    for p in {{pkgs}}; do
      fold=""
      case " {{nofold}} " in *" $p "*) fold="--no-folding" ;; esac
      stow --verbose {{action}} $fold "$p"
    done
