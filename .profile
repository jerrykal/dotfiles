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
--border \
--bind 'ctrl-u:preview-page-up,ctrl-d:preview-page-down' \
--color=fg:#908caa,bg:#191724,hl:#ebbcba \
--color=fg+:#e0def4,bg+:#26233a,hl+:#ebbcba \
--color=border:#403d52,header:#31748f,gutter:#191724 \
--color=spinner:#f6c177,info:#9ccfd8 \
--color=pointer:#c4a7e7,marker:#eb6f92,prompt:#908caa"
  fzf_ctrl_t_all_cmd="find . -path '*/.*' -prune -o -mindepth 1 -print 2>/dev/null"
  fzf_ctrl_t_level1_cmd="find . -mindepth 1 -maxdepth 1 -type d ! -name '.*' 2>/dev/null"

  if command -v eza >/dev/null 2>&1; then
    fzf_eza_cmd="eza -a1 --group-directories-first --color=always {}"

    if command -v bat >/dev/null 2>&1; then
      fzf_bat_cmd="bat -n --color=always {}"
      fzf_ctrl_t_preview="--preview 'if test -d {}; then $fzf_eza_cmd; else $fzf_bat_cmd; fi'"
    else
      fzf_ctrl_t_preview="--preview '$fzf_eza_cmd'"
    fi

    export FZF_ALT_C_OPTS="--preview '$fzf_eza_cmd'"
  elif command -v bat >/dev/null 2>&1; then
    fzf_bat_cmd="bat -n --color=always {}"
    fzf_ctrl_t_preview="--preview 'if test -d {}; then ls -a1 {}; else $fzf_bat_cmd; fi'"
  else
    fzf_ctrl_t_preview="--preview 'ls -a1 {}'"
  fi

  export FZF_CTRL_T_COMMAND="$fzf_ctrl_t_all_cmd"
  export FZF_CTRL_T_OPTS="$fzf_ctrl_t_preview --prompt 'all> ' --header 'CTRL-L: toggle level-1 dirs' --bind 'ctrl-l:transform:[ \"\$FZF_PROMPT\" = \"all> \" ] && echo \"change-prompt(level1> )+reload($fzf_ctrl_t_level1_cmd)\" || echo \"change-prompt(all> )+reload($fzf_ctrl_t_all_cmd)\"'"
fi
