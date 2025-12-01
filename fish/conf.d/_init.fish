# Things here are loaded first

# --- Paths ---
set -e fish_user_paths
fish_add_path $HOME/.cargo/bin
fish_add_path $HOME/.local/bin
fish_add_path /opt/homebrew/bin

# Add linuxbrew to path if it exists
if test -x /home/linuxbrew/.linuxbrew/bin/brew
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
end

# -- Environment Variables --
if type -q nvim
    set -gx EDITOR (which nvim)
    set -gx MANPAGER "nvim +Man!"
end

set -gx VISUAL $EDITOR
set -gx SUDO_EDITOR $EDITOR

# --- fisher ---
_init_fisher
