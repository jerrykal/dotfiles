# Dotfiles

My personal dotfiles.

## Requirements

Ensure that GNU Stow is installed. Either build from source using the `scripts/install_stow.sh` script or install it via Homebrew with `brew install stow` on macOS.

The `scripts/install_stow.sh` script installs Stow in `$HOME/.local/bin`, so be sure to include this directory in your `$PATH`.

## Installation

Configuration files are organized into subdirectories, with the exception of the `scripts/` directory. To install a specific config, use the command `stow <config-name>`.

For instance, to install Neovim configurations, execute the following command:

```shell
stow neovim
```

This suffices for most configurations. However, some configurations require additional arguments, which are specified in the following sections.

### Fish shell

```shell
stow --no-folding fish
```

### Lazygit

```shell
stow --target=$(lazygit --print-config-dir) lazygit
```
