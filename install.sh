#!/usr/bin/env bash

#
# This script installs/updates tool dependencies (using Homebrew and Brewfile)
# and then sets up dotfiles by creating symbolic links using 'stow'.
#
# Usage: ./install.sh [--skip-deps]
#
# Option:
#   --skip-deps : Skip the dependency installation and update step.
#

for arg in "$@"; do
  case "$arg" in
  --skip-deps) SKIP_DEPS=1 ;;
  *) ;;
  esac
done

log() {
  local log_level=$1
  shift
  local message="$*"
  local reset="\033[0m"
  local red="\033[31m"
  local yellow="\033[33m"
  local green="\033[32m"
  local color timestamp
  timestamp=$(date +"%Y-%m-%d %H:%M:%S")

  case "$log_level" in
  ERROR) color=$red ;;
  WARN) color=$yellow ;;
  INFO) color=$green ;;
  *) color=$reset ;;
  esac
  echo -e "${color}${timestamp} [${log_level}]${reset} ${message}"
}

# install_if_missing <bin> <install_cmd_str>
# install_cmd_str is eval'd lazily so it only runs when the binary is missing.
install_if_missing() {
  local bin=$1 install_cmd=$2
  log INFO "Checking for $bin installation..."
  if command -v "$bin" &>/dev/null; then
    log INFO "$bin is already installed."
    return 0
  fi
  log INFO "$bin not found. Installing..."
  if eval "$install_cmd"; then
    log INFO "$bin installation successful."
  else
    log ERROR "$bin installation failed."
    exit 1
  fi
}

if [ -z "${SKIP_DEPS:-}" ]; then
  install_if_missing brew \
    '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'

  brew_path_candidates=(/opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew)
  for p in "${brew_path_candidates[@]}"; do
    if [ -x "$p" ]; then
      log INFO "Activating Homebrew (via 'eval \"\$($p shellenv)\"')"
      eval "$("$p" shellenv)"
      break
    fi
  done

  if command -v brew &>/dev/null; then
    log INFO "Homebrew activation successful."
  else
    log ERROR "Homebrew activation failed."
    exit 1
  fi

  log INFO "Installing/Updating Homebrew packages defined in Brewfile (via 'brew bundle install')..."
  if brew bundle install; then
    log INFO "Homebrew packages installed/updated successfully."
  else
    log WARN "Homebrew package installation encountered issues."
  fi

  install_if_missing claude \
    'curl -fsSL https://claude.ai/install.sh | bash'
fi

log INFO "Linking dotfiles with 'just link'..."
if command -v just &>/dev/null; then
  link_ok=0
  just link && link_ok=1
else
  # Bootstrap fallback: 'just' not on PATH yet (e.g. --skip-deps on a fresh box).
  # Mirror the justfile: fold by default, --no-folding for the runtime-heavy pkgs.
  log WARN "'just' not found; falling back to direct stow invocation."
  packages="atuin bat bin claude eza fish git lazygit mise nvim opencode ruff sesh shell tmux"
  nofold=" claude fish nvim tmux "
  link_ok=1
  for p in $packages; do
    case "$nofold" in *" $p "*) fold="--no-folding" ;; *) fold="" ;; esac
    stow --verbose $fold "$p" || link_ok=0
  done
fi

if [ "$link_ok" = 1 ]; then
  log INFO "Dotfiles linked successfully."
else
  log WARN "Linking encountered issues. Check your dotfiles setup."
fi
