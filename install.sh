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
  --skip-deps)
    SKIP_DEPS=1
    ;;
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
  local timestamp=$(date +"%Y-%m-%d %H:%M:%S")

  case "$log_level" in
  ERROR)
    color=$red
    ;;
  WARN)
    color=$yellow
    ;;
  INFO)
    color=$green
    ;;
  *)
    color=$reset
    ;;
  esac
  echo -e "${color}${timestamp} [${log_level}]${reset} ${message}"
}

if [ ! -n "$SKIP_DEPS" ]; then
  log INFO "Checking for Homebrew installation..."
  if ! command -v brew &>/dev/null; then
    echo "Homebrew not found. Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    if [ $? -eq 0 ]; then
      log INFO "Homebrew installation successful."
    else
      log ERROR "Homebrew installation failed."
      exit 1
    fi
  else
    log INFO "Homebrew is already installed."
  fi

  brew_path_candidate=(/opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew)
  for p in "${brew_path_candidate[@]}"; do
    if [ -x "$p" ]; then
      log INFO "Activating Homebrew (via 'eval \"\$($p shellenv)\"')"
      eval "$("$p" shellenv)"
      break
    fi
  done

  if command -v brew &>/dev/null; then
    log INFO "Homebrew activation successfull."
  else
    log ERROR "Homebrew activation failed."
    exit 1
  fi

  log INFO "Installing/Updating Homebrew packages defined in Brewfile (via 'brew bundle install')..."
  brew bundle install

  if [ $? -eq 0 ]; then
    log INFO "Homebrew packages installed/updated successfully."
  else
    log WARNING "Homebrew package installation encountered issues."
  fi
fi

log INFO "Setting up dotfiles using 'stow'..."
stow .

if [ $? -eq 0 ]; then
  log INFO "Dotfiles set up successfully using 'stow'."
else
  log WARNING "'stow' execution encountered issues. Check your dotfiles setup."
fi

log INFO "Changing default shell to fish"

sudo chsh -s "$(which fish)"

if [ $? -eq 0 ]; then
  log INFO "Successfully changed the default shell to zsh."
  log INFO "Please log out and log back in for the changes to take effect."
else
  log ERROR "Failed to change the default shell."
  exit 1
fi
