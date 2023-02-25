# Activate zoxide
if type -q zoxide
   zoxide init fish | source
end

set -gx fish_greeting ""
set -gx EDITOR nvim

# Path
fish_add_path -g ~/.cargo/bin
fish_add_path -g ~/.local/bin

# Updates PATH for the Google Cloud SDK.
if [ -f "$HOME/.google-cloud-sdk/path.fish.inc" ]; . "$HOME/.google-cloud-sdk/path.fish.inc"; end

set -gx PYENV_ROOT $HOME/.pyenv
fish_add_path -g $PYENV_ROOT/bin
pyenv init - | source
pyenv virtualenv-init - | sed "s/--on-event fish_prompt/--on-variable PWD --on-event init_done/g" | source

# Aliases
if type -q exa
   alias ls="exa --group-directories-first"
   alias tree="ls --tree"
end

if type -q xclip
   alias pbcopy="xclip -selection clipboard"
   alias pbpaste="xclip -selection clipboard -o"
end

# Abbreviations
abbr -a lsl ls -l
abbr -a lsa ls -a

abbr -a rs rsync -avh

abbr -a g git
abbr -a gi git init
abbr -a ga git add
abbr -a gaa git add --all
abbr -a gc git commit -v
abbr -a gcm git commit -m
abbr -a gst git status
abbr -a gss git status -s
abbr -a gl git log
abbr -a glo git log --oneline
abbr -a gd git diff
abbr -a gds git diff --staged
abbr -a gls git ls-files
abbr -a gp git push

abbr -a cnd conda
abbr -a ca conda activate
abbr -a cda conda deactivate
abbr -a ci conda install
abbr -a ccr conda create
abbr -a ce conda env
abbr -a cee conda env export
abbr -a cec conda env create
abbr -a cer conda env remove
abbr -a cel conda env list
abbr -a cl conda list

abbr -a py python
abbr -a pipl pip list
abbr -a pipi pip install
abbr -a pipir pip install -r requirements.txt
abbr -a pipx pip uninstall
abbr -a pipsh pip show
abbr -a pipsr pip search
abbr -a pipfr pip freeze
abbr -a --set-cursor tsb tensorboard --logdir=%
abbr -a jl jupyter-lab
abbr -a da deactivate

abbr -a gcp gcloud compute

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

# Change some colors for pure-fish prompt
set -g pure_color_primary brblue
set -g pure_color_success D27E99

emit init_done
