if type -q eza
   alias ls="eza --color=always --group-directories-first"
   alias tree="ls --tree"
end

type -q bat; and alias cat="bat"
type -q batcat; and alias cat="batcat"
