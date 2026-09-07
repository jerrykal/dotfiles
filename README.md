# Dotfiles

My personal dotfiles, managed with [`mise bootstrap`](https://mise.jdx.dev/bootstrap.html).

## Fresh machine

```sh
curl -fsSL https://raw.githubusercontent.com/jerrykal/dotfiles/main/install.sh | sh
mise run setup:git "Your Name" you@example.com   # git identity -> ~/.gitconfig.local (prompts if omitted)
```

## Day to day

```sh
mise bootstrap                        # converge packages, dotfiles, tools
mise bootstrap dotfiles status        # what is linked / missing / drifted
mise bootstrap dotfiles apply         # (re)link after adding tracked files
mise bootstrap dotfiles unapply       # remove the links
mise run update:all                   # brew, mise + tools, nvim/fish/tmux plugins, skills, then pull + converge (-n = dry run, -c = keep going)
mise run clean                        # prune brew/mise/uv/go caches and unused nvim plugins
```

Each top-level dir is one tool's config; `mise.toml` maps it to its `$HOME`
target. Tool versions live in `mise/config.toml`, the global mise config.
