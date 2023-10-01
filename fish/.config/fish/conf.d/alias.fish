if type -q exa
   alias ls="exa --color=always --group-directories-first"
   alias tree="ls --tree"
end

if type -q xclip
   alias pbcopy="xclip -selection clipboard"
   alias pbpaste="xclip -selection clipboard -o"
end

alias ssh="TERM=xterm-256color $(which ssh)"
