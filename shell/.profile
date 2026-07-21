# One-time env setup (XDG, brew, EDITOR, fzf) is guarded against nested shells.
# PATH is re-asserted on every shell (bottom): macOS path_helper reorders it on
# each login, demoting our prepends below /etc/paths entries like /usr/local/bin.

if [ -z "$__PROFILE_SOURCED" ]; then
  export __PROFILE_SOURCED=1

  # XDG basedirs
  [ -z "$XDG_CONFIG_HOME" ] && export XDG_CONFIG_HOME="$HOME/.config"
  [ -z "$XDG_DATA_HOME" ] && export XDG_DATA_HOME="$HOME/.local/share"
  [ -z "$XDG_STATE_HOME" ] && export XDG_STATE_HOME="$HOME/.local/state"
  [ -z "$XDG_CACHE_HOME" ] && export XDG_CACHE_HOME="$HOME/.cache"

  # Homebrew (PATH order re-asserted below)
  if [ -x "/opt/homebrew/bin/brew" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -x "/usr/local/bin/brew" ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  elif [ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  fi

  # Editor
  if command -v nvim >/dev/null 2>&1; then
    export EDITOR="$(command -v nvim)"
    export MANPAGER="nvim +Man!"
  fi

  export VISUAL="$EDITOR"
  export SUDO_EDITOR="$EDITOR"

  # fzf
  if command -v fzf >/dev/null 2>&1; then
    export FZF_DEFAULT_OPTS="
--tmux=80%,70%
--layout reverse
--border
--bind 'ctrl-u:preview-page-up,ctrl-d:preview-page-down'
--color=fg:#908caa,bg:#191724,hl:#ebbcba
--color=fg+:#e0def4,bg+:#26233a,hl+:#ebbcba
--color=border:#403d52,header:#31748f,gutter:#191724
--color=spinner:#f6c177,info:#9ccfd8,label:#6e6a86
--color=pointer:#c4a7e7,marker:#eb6f92,prompt:#908caa"

    if command -v eza >/dev/null 2>&1; then
      fzf_dir_preview="eza -a1 --group-directories-first --color=always {}"
    else
      fzf_dir_preview="ls -a1 {}"
    fi

    if command -v bat >/dev/null 2>&1; then
      fzf_file_preview="bat -n --color=always {}"
    else
      fzf_file_preview="cat {}"
    fi

    export FZF_ALT_C_OPTS="--preview '$fzf_dir_preview'"
    export FZF_CTRL_T_OPTS="--preview 'if test -d {}; then $fzf_dir_preview; else $fzf_file_preview; fi'"
    unset fzf_dir_preview fzf_file_preview
  fi

  # Claude
  export CLAUDE_CODE_TMUX_TRUECOLOR=true

  # Machine-local config (untracked)
  [ -f "$HOME/.profile.local" ] && . "$HOME/.profile.local"
fi

# Paths — re-asserted on every shell (see header). Strips any existing occurrence
# before prepending, so repeat sourcing can't demote or duplicate. Last call wins,
# so higher priority goes lower here.
_path_prepend() {
  d=$1
  [ -d "$d" ] || return
  PATH=$(printf '%s' ":$PATH:" | sed "s|:$d:|:|g")
  PATH=${PATH#:}
  PATH=${PATH%:}
  PATH="$d:$PATH"
}

# Keep Homebrew ahead of /usr/local/bin (path_helper demotes it each login)
_path_prepend /opt/homebrew/sbin
_path_prepend /opt/homebrew/bin

_path_prepend "$HOME/.cargo/bin"
_path_prepend "$HOME/.local/bin"

# mise shims, so mise tools resolve where fish's `mise activate` never runs
_path_prepend "$HOME/.local/share/mise/shims"

# CUDA
_path_prepend /usr/local/cuda/bin

export PATH
unset -f _path_prepend
