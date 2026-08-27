#!/usr/bin/env bash
#
# Bootstrap a fresh machine: install Homebrew + Brewfile deps, mise, and
# Claude Code, then link the dotfiles with `just`. For day-to-day linking use
# `just link` directly.
#
# Usage: ./install.sh [--skip-deps]   # --skip-deps: link only (deps assumed present)
#
set -euo pipefail
cd "$(dirname "$0")"

log() { printf '\033[32m[install]\033[0m %s\n' "$*"; }

if [[ "${1:-}" != "--skip-deps" ]]; then
  if ! command -v brew &>/dev/null; then
    log "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  # Put brew (and thus just, stow) on PATH for the rest of this script.
  for p in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
    [[ -x "$p" ]] && eval "$("$p" shellenv)" && break
  done

  log "Installing Brewfile packages..."
  brew bundle install || log "warning: some Homebrew packages failed; continuing."

  # mise's official installer (https://mise.jdx.dev/installing-mise.html)
  # drops the binary in ~/.local/bin; shell/.profile puts that on PATH.
  log "Installing mise..."
  command -v mise &>/dev/null || [[ -x "$HOME/.local/bin/mise" ]] || curl -fsSL https://mise.run | sh

  log "Installing Claude Code..."
  command -v claude &>/dev/null || curl -fsSL https://claude.ai/install.sh | bash
fi

if ! command -v just &>/dev/null; then
  echo "error: 'just' not found; run without --skip-deps to install dependencies." >&2
  exit 1
fi

log "Linking dotfiles..."
just link
log "Done."
