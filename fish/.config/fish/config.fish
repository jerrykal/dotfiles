set -gx fish_greeting

set -gx EDITOR (which nvim)
set -gx VISUAL $EDITOR
set -gx SUDO_EDITOR $EDITOR

set -x LC_ALL en_US.UTF-8
set -x LANG en_US.UTF-8
set -x LANGUAGE en_US.UTF-8

# Cursor shapes
set -g fish_vi_force_cursor
set -g fish_cursor_default block blink
set -g fish_cursor_insert line blink
set -g fish_cursor_replace_one underscore blink
set -g fish_cursor_visual block

set -g fish_key_bindings fish_hybrid_key_bindings

# Correct colors on ssh (see: https://github.com/fish-shell/fish-shell/issues/7701)
test -n "$SSH_CLIENT"; or test -n "$SSH_TTY"; and set -g fish_term24bit 1

# Initialize zoxide
type -q zoxide; and zoxide init fish | source

# Initialize thefuck
type -q thefuck; and thefuck --alias | source

# Initialize pyenv
set -gx PYENV_ROOT $HOME/.pyenv
if test -e $PYENV_ROOT
    fish_add_path -g $PYENV_ROOT/bin

    pyenv init - | source
    pyenv virtualenv-init - | sed "s/--on-event fish_prompt/--on-variable PWD --on-event init_done/g" | source
end

# Remove unwanted newline at the prompt for vscode shell integration
if type -q __vsc_fish_prompt
    functions -c __vsc_fish_prompt __original_vsc_fish_prompt
    function __vsc_fish_prompt
        printf "%b" (string join "\n" (__original_vsc_fish_prompt))
    end
end

# iTerm2 shell integration
test -e $HOME/.iterm2_shell_integration.fish; and source $HOME/.iterm2_shell_integration.fish

# Init done
emit init_done
