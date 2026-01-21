# Disable greeting
set -gx fish_greeting

# Cursor shapes
set -gx fish_vi_force_cursor
set -gx fish_cursor_default block blink
set -gx fish_cursor_insert line blink
set -gx fish_cursor_replace_one underscore blink
set -gx fish_cursor_visual block

# Initialize fzf
type -q fzf; and fzf --fish | source

# Initialize atuin
type -q atuin; and atuin init fish --disable-up-arrow | source

# Initialize zoxide
type -q zoxide; and zoxide init fish | source

# Hook direnv
type -q direnv; and direnv hook fish | source
