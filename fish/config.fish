# Disable greeting
set -g fish_greeting

status is-interactive; or return

# Cursor shapes
set -g fish_vi_force_cursor
set -g fish_cursor_default block blink
set -g fish_cursor_insert line blink
set -g fish_cursor_replace_one underscore blink
set -g fish_cursor_visual block

# Activate mise
type -q mise; and mise activate fish | source

# Initialize fzf
type -q fzf; and fzf --fish | source

# Initialize atuin
type -q atuin; and atuin init fish --disable-up-arrow | source

# Initialize zoxide
type -q zoxide; and zoxide init fish | source

# Machine-local config, gitignored
test -f $__fish_config_dir/local.fish; and source $__fish_config_dir/local.fish

# conda is lazy-loaded from conf.d/conda.fish — never let `conda init` add its
# block here, it is sourced later and would undo the lazy stubs.
