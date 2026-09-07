#!/bin/sh
# Fresh machine:  curl -fsSL https://raw.githubusercontent.com/jerrykal/dotfiles/main/install.sh | sh
# Installs mise, clones this repo to ~/.dotfiles, moves aside any existing
# files that mise.toml would replace (to ~/.dotfiles-backup-<timestamp>, same
# layout as ~), then `mise bootstrap` converges packages, dotfiles and tools.
# Re-runnable: an existing ~/.dotfiles is converged in place.
set -eu
DIR="$HOME/.dotfiles"
BAK="$HOME/.dotfiles-backup-$(date +%Y%m%d%H%M%S)"
command -v mise >/dev/null 2>&1 || [ -x "$HOME/.local/bin/mise" ] || curl -fsSL https://mise.run | sh
PATH="$HOME/.local/bin:$PATH"
if [ ! -d "$DIR/.git" ]; then
  git clone https://github.com/jerrykal/dotfiles.git "$DIR"
  git -C "$DIR" remote set-url origin git@github.com:jerrykal/dotfiles.git
fi
mise trust --quiet "$DIR/mise.toml"
mise -C "$DIR" bootstrap dotfiles apply --dry-run 2>&1 | sed -n 's|^  ~/||p' | while IFS= read -r f; do
  mkdir -p "$BAK/$(dirname "$f")" && mv "$HOME/$f" "$BAK/$f" && echo "backed up ~/$f -> $BAK/$f"
done
mise -C "$DIR" bootstrap --yes
