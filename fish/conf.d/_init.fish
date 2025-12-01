# Things here are loaded first

# Set XDG basedirs.
# https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
set -q XDG_CONFIG_HOME; or set -gx XDG_CONFIG_HOME $HOME/.config
set -q XDG_DATA_HOME; or set -gx XDG_DATA_HOME $HOME/.local/share
set -q XDG_STATE_HOME; or set -gx XDG_STATE_HOME $HOME/.local/state
set -q XDG_CACHE_HOME; or set -gx XDG_CACHE_HOME $HOME/.cache
for xdgdir in (path filter -vd $XDG_CONFIG_HOME $XDG_DATA_HOME $XDG_STATE_HOME $XDG_CACHE_HOME)
    mkdir -p $xdgdir
end

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
