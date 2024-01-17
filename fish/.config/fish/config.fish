set -gx fish_greeting

set -gx EDITOR (which nvim)
set -gx VISUAL $EDITOR
set -gx SUDO_EDITOR $EDITOR

set -x LC_ALL en_US.UTF-8
set -x LANG en_US.UTF-8
set -x LANGUAGE en_US.UTF-8

# Cursor shapes
set fish_cursor_default block blink
set fish_cursor_insert line blink
set fish_cursor_replace_one underscore blink
set fish_cursor_visual block

set -g fish_key_bindings fish_hybrid_key_bindings

# Correct colors on ssh (see: https://github.com/fish-shell/fish-shell/issues/7701)
if test -n "$SSH_CLIENT"  || test -n "$SSH_TTY"
    set -g fish_term24bit 1
end

# Initialize zoxide
if type -q zoxide
   zoxide init fish | source
end

# Initialize pyenv
set -gx PYENV_ROOT $HOME/.pyenv
if test -e $PYENV_ROOT
    fish_add_path -g $PYENV_ROOT/bin

    pyenv init - | source
    pyenv virtualenv-init - | sed "s/--on-event fish_prompt/--on-variable PWD --on-event init_done/g" | source
end

# Init done
emit init_done
