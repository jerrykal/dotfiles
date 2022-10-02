set -gx fish_greeting ''
set -gx EDITOR nvim

if type -q exa
  alias ls='exa'
  alias tree='exa --tree'
end
if type -q xclip
  alias pbcopy='xclip -selection clipboard'
  alias pbpaste='xclip -selection clipboard -o'
end
alias python='python3'

set -g fish_color_autosuggestion brblack
set -g fish_color_command blue
set -g fish_color_comment brblack --bold
set -g fish_color_end green
set -g fish_color_error red --bold
set -g fish_color_escape magenta
set -g fish_color_keyword magenta
set -g fish_color_normal normal
set -g fish_color_operator green
set -g fish_color_param cyan
set -g fish_color_quote yellow
set -g fish_color_redirection blue
set -g fish_color_search_match --background=brblack
set -g fish_color_selection --background=brblack
set -g fish_pager_color_completion normal
set -g fish_pager_color_description brblack
set -g fish_pager_color_prefix blue --bold
set -g fish_pager_color_progress brblack
