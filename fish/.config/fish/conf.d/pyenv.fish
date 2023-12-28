# Initialize pyenv
set -gx PYENV_ROOT $HOME/.pyenv
if test -e $PYENV_ROOT
    fish_add_path -g $PYENV_ROOT/bin

    pyenv init - | source
    pyenv virtualenv-init - | sed "s/--on-event fish_prompt/--on-variable PWD --on-event init_done/g" | source
end
