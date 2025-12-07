# Set XDG basedirs
[ -z "$XDG_CONFIG_HOME" ] && export XDG_CONFIG_HOME="$HOME/.config"
[ -z "$XDG_DATA_HOME" ] && export XDG_DATA_HOME="$HOME/.local/share"
[ -z "$XDG_STATE_HOME" ] && export XDG_STATE_HOME="$HOME/.local/state"
[ -z "$XDG_CACHE_HOME" ] && export XDG_CACHE_HOME="$HOME/.cache"

# Homebrew
if [ -d "/opt/homebrew" ]; then
  export PATH="/opt/homebrew/bin:$PATH"
elif [ -d "/usr/local/homebrew" ]; then
  export PATH="/usr/local/bin:$PATH"
elif [ -d "/home/linuxbrew/.linuxbrwe" ]; then
  export PATH="/home/linuxbrew/.linuxbrwe:$PATH"
fi

# Other paths
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# Environment Variables
if command -v nvim >/dev/null 2>&1; then
  export EDITOR="$(command -v nvim)"
  export MANPAGER="nvim +Man!"
fi

export VISUAL="$EDITOR"
export SUDO_EDITOR="$EDITOR"
