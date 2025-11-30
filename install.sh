#!/usr/bin/env bash

echo "Checking for Homebrew installation..."
if ! command -v brew &>/dev/null; then
  echo "Homebrew not found. Installing..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if [ $? -eq 0 ]; then
    echo "Homebrew installation successful."
  else
    echo "ERROR: Homebrew installation failed."
    exit 1
  fi
else
  echo "Homebrew is already installed."
fi
test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

echo "Installing/Updating Homebrew packages defined in Brewfile (via 'brew bundle install')..."
brew bundle install

if [ $? -eq 0 ]; then
  echo "Homebrew packages installed/updated successfully."
else
  echo "WARNING: Homebrew package installation encountered issues."
fi

echo "Setting up dotfiles using 'stow'..."
stow .

if [ $? -eq 0 ]; then
  echo "Dotfiles set up successfully using 'stow'."
else
  echo "WARNING: 'stow' execution encountered issues. Check your dotfiles setup."
fi
