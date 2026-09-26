# Disable greeting
set -g fish_greeting

status is-interactive; or return

fish_config theme choose "Rosé Pine"

# pure's container detection forks `uname` every prompt and needs /proc
test -e /proc/1/cgroup; or set -g pure_enable_container_detection false

# Activate mise
command -q mise; and mise activate fish | source

# Initialize fzf; atuin owns ctrl-r, so skip fzf's history widget
command -q atuin; and set -g FZF_CTRL_R_COMMAND ''
command -q fzf; and fzf --fish | source

# Initialize atuin
command -q atuin; and atuin init fish --disable-up-arrow | source

# Initialize zoxide
command -q zoxide; and zoxide init fish | source

# Ghostty shell integration — Ghostty only auto-injects it into the shell it
# spawns, but our setup launches fish via exec fish, so fish must source it itself.
set -q GHOSTTY_RESOURCES_DIR; and source $GHOSTTY_RESOURCES_DIR/shell-integration/fish/vendor_conf.d/ghostty-shell-integration.fish

# Machine-local config, gitignored
test -f $__fish_config_dir/local.fish; and source $__fish_config_dir/local.fish

# conda is lazy-loaded from conf.d/conda.fish — never let `conda init` add its
# block here, it is sourced later and would undo the lazy stubs.
