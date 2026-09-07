#!/bin/sh
# Fresh machine:  curl -fsSL https://raw.githubusercontent.com/jerrykal/dotfiles/main/install.sh | sh
# Installs mise, then `mise bootstrap` clones this repo to ~/.dotfiles and
# converges packages, dotfiles and tools from its mise.toml. Re-runnable.
set -eu
DIR="$HOME/.dotfiles"
command -v mise >/dev/null 2>&1 || [ -x "$HOME/.local/bin/mise" ] || curl -fsSL https://mise.run | sh
PATH="$HOME/.local/bin:$PATH"
if [ -d "$DIR/.git" ]; then
  mise trust --quiet "$DIR/mise.toml" && mise -C "$DIR" bootstrap --yes
else
  mise bootstrap --from https://github.com/jerrykal/dotfiles.git --from-dir "$DIR" --yes
  git -C "$DIR" remote set-url origin git@github.com:jerrykal/dotfiles.git
fi
