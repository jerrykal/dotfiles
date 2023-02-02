# Activate zoxide
if type -q zoxide
   zoxide init fish | source
end

# Activate starship
if type -q starship
    starship init fish | source
end

set -gx fish_greeting ""
set -gx EDITOR nvim

# Path
fish_add_path ~/.cargo/bin
fish_add_path ~/.local/bin

# Updates PATH for the Google Cloud SDK.
if [ -f "$HOME/.google-cloud-sdk/path.fish.inc" ]; . "$HOME/.google-cloud-sdk/path.fish.inc"; end

# Aliases
if type -q exa
   alias ls="exa --group-directories-first"
   alias tree="ls --tree"
end
if type -q xclip
   alias pbcopy="xclip -selection clipboard"
   alias pbpaste="xclip -selection clipboard -o"
end

# Kanagawa Fish shell theme
# A template was taken and modified from Tokyonight:
# https://github.com/folke/tokyonight.nvim/blob/main/extras/fish_tokyonight_night.fish
set -l foreground DCD7BA
set -l selection 2D4F67
set -l comment 727169
set -l red C34043
set -l orange FF9E64
set -l yellow C0A36E
set -l green 76946A
set -l purple 957FB8
set -l cyan 7AA89F
set -l pink D27E99

# Syntax Highlighting Colors
set -g fish_color_normal $foreground
set -g fish_color_command $cyan
set -g fish_color_keyword $pink
set -g fish_color_quote $yellow
set -g fish_color_redirection $foreground
set -g fish_color_end $orange
set -g fish_color_error $red
set -g fish_color_param $purple
set -g fish_color_comment $comment
set -g fish_color_selection --background=$selection
set -g fish_color_search_match --background=$selection
set -g fish_color_operator $green
set -g fish_color_escape $pink
set -g fish_color_autosuggestion $comment

# Completion Pager Colors
set -g fish_pager_color_progress $comment
set -g fish_pager_color_prefix $cyan
set -g fish_pager_color_completion $foreground
set -g fish_pager_color_description $comment
