# Set XDG basedirs
[ -z "$XDG_CONFIG_HOME" ] && export XDG_CONFIG_HOME="$HOME/.config"
[ -z "$XDG_DATA_HOME" ] && export XDG_DATA_HOME="$HOME/.local/share"
[ -z "$XDG_STATE_HOME" ] && export XDG_STATE_HOME="$HOME/.local/state"
[ -z "$XDG_CACHE_HOME" ] && export XDG_CACHE_HOME="$HOME/.cache"

# Homebrew
if [ -x "/opt/homebrew/bin/brew" ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x "/usr/local/homebrew/bin/brew" ]; then
  eval "$(/usr/local/homebrew/bin/brew shellenv)"
elif [ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Paths
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# Environment Variables
if command -v nvim >/dev/null 2>&1; then
  export EDITOR="$(command -v nvim)"
  export MANPAGER="nvim +Man!"
fi

export VISUAL="$EDITOR"
export SUDO_EDITOR="$EDITOR"

# fzf configs
if command -v fzf >/dev/null 2>&1; then
  export FZF_DEFAULT_OPTS="\
--layout reverse \
--bind 'ctrl-u:preview-page-up,ctrl-d:preview-page-down' \
--color=fg:#908caa,bg:#191724,hl:#ebbcba \
--color=fg+:#e0def4,bg+:#26233a,hl+:#ebbcba \
--color=border:#403d52,header:#31748f,gutter:#191724 \
--color=spinner:#f6c177,info:#9ccfd8 \
--color=pointer:#c4a7e7,marker:#eb6f92,prompt:#908caa"

  if command -v bat >/dev/null 2>&1; then
    fzf_bat_cmd="bat -n --color=always {}"

    if command -v eza >/dev/null 2>&1; then
      fzf_eza_cmd="eza -a1 --group-directories-first --color=always {}"

      export FZF_CTRL_T_OPTS="--preview 'if test -d {}; then $fzf_eza_cmd; else $fzf_bat_cmd; fi'"
      export FZF_ALT_C_OPTS="--preview '$fzf_eza_cmd'"
    else
      export FZF_CTRL_T_OPTS="--preview '$fzf_bat_cmd'"
    fi
  fi
fi
