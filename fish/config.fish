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

# Ghostty shell integration — Ghostty only auto-injects it into the shell it
# spawns, but our setup launches fish via exec fish, so fish must source it itself.
set -q GHOSTTY_RESOURCES_DIR; and source $GHOSTTY_RESOURCES_DIR/shell-integration/fish/vendor_conf.d/ghostty-shell-integration.fish

# Machine-local config, gitignored
test -f $__fish_config_dir/local.fish; and source $__fish_config_dir/local.fish

# conda is lazy-loaded from conf.d/conda.fish — never let `conda init` add its
# block here, it is sourced later and would undo the lazy stubs.
