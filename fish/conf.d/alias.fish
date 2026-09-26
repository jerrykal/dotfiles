status is-interactive; or return

command -q bat; and alias cat="bat"
command -q batcat; and alias cat="batcat"; and alias bat="batcat"

if command -q eza
    alias ls="eza --icons=auto --group-directories-first --git"
    alias tree="ls --tree"
end

alias mkdir="mkdir -p"

alias t="~/.config/tmux/scripts/session-picker.sh"
