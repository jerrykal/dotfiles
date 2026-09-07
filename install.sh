#!/usr/bin/env bash
#
# Bootstrap a fresh machine. Installs mise, then lets `mise bootstrap` clone
# this repo to ~/.dotfiles and converge everything declared in ./mise.toml:
# Homebrew packages, dotfile symlinks, and the tools in mise/config.toml.
# Day to day, run `mise bootstrap` (or `mise bootstrap dotfiles apply`) from
# ~/.dotfiles instead.
set -euo pipefail
command -v mise >/dev/null || [[ -x "$HOME/.local/bin/mise" ]] || curl -fsSL https://mise.run | sh
export PATH="$HOME/.local/bin:$PATH"
mise bootstrap --from git@github.com:jerrykal/dotfiles.git --from-dir "$HOME/.dotfiles" --yes
