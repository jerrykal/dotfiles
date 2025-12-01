# Disable greeting
set -gx fish_greeting

# Cursor shapes
set -gx fish_vi_force_cursor
set -gx fish_cursor_default block blink
set -gx fish_cursor_insert line blink
set -gx fish_cursor_replace_one underscore blink
set -gx fish_cursor_visual block

# Initialize zoxide
type -q zoxide; and zoxide init fish | source

# Initialize thefuck
if type -q thefuck
    thefuck --alias | source
end

# Remove unwanted newline at the prompt for vscode shell integration
if type -q __vsc_fish_prompt
    functions -c __vsc_fish_prompt __original_vsc_fish_prompt
    function __vsc_fish_prompt
        printf "%b" (string join "\n" (__original_vsc_fish_prompt))
    end
end

# Init done
emit init_done
