if type -q exa
   alias ls="exa --color=always --group-directories-first"
   alias tree="ls --tree"
end

type -q bat; and alias cat="bat"
type -q batcat; and alias cat="batcat"
