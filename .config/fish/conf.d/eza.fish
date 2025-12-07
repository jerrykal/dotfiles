if not type -q eza
    return
end

set -gx EZA_CONFIG_DIR $XDG_CONFIG_HOME/eza

alias ls="eza --color=always --group-directories-first"
alias tree="ls --tree"
