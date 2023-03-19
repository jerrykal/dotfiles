set -gx fish_greeting

set -gx EDITOR (which nvim)
set -gx VISUAL $EDITOR
set -gx SUDO_EDITOR $EDITOR

# Correct colors on ssh (see: https://github.com/fish-shell/fish-shell/issues/7701)
if test -n "$SSH_CLIENT"  || test -n "$SSH_TTY"
    set -g fish_term24bit 1
end

# Initialize pyenv
set -gx PYENV_ROOT $HOME/.pyenv
if test -d "$PYENV_ROOT/bin"
    fish_add_path -g $PYENV_ROOT/bin

    pyenv init - | source
    pyenv virtualenv-init - | sed "s/--on-event fish_prompt/--on-variable PWD --on-event init_done/g" | source
end

# Initialize zoxide
if type -q zoxide
   zoxide init fish | source
end

# Init done
emit init_done
