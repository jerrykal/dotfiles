# Dotfiles

My personal dotfiles.

## Requirements

Ensure that GNU Stow is installed. Either build from source using the `scripts/install-stow.sh` script or install it via Homebrew with `brew install stow` on macOS.

The `scripts/install-stow.sh` script installs Stow in `$HOME/.local/bin`, so be sure to include this directory in your `$PATH`.

## Setup

Configuration files are organized into subdirectories under the `configs/` directory. Most configurations can be installed by running `stow <config-name>`.

For instance, to install Neovim configurations, execute the following command:

```shell
stow neovim
```

This suffices for most configurations. However, some configurations require additional arguments or manual setup, which are specified in the following sections.

### Fish shell

```shell
stow --no-folding fish
```

### iTerm2

To configure iTerm2, navigate to `Settings->General->Settings`, check the option `Load preferences from a custom folder or URL`, and choose the `<path-to-dotfiles>/configs/iterm2` as the location for the custom folder.

### Lazygit

```shell
stow --target=$(lazygit --print-config-dir) lazygit
```
