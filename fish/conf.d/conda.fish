# Lazy-load conda. `conda shell.fish hook` costs ~0.5s per shell, so defer it
# until conda is actually needed. The stubs below erase themselves, source the
# real hook, and re-dispatch.
#
# Do NOT let `conda init` write its block into config.fish — it is sourced
# after conf.d and would clobber these stubs with the eager hook.

function __conda_lazy_init --description "Source the real conda shell hook"
    functions -e conda python pip

    # Honor an inherited CONDA_EXE (shell spawned from an active env),
    # otherwise probe the usual install prefixes.
    if set -q CONDA_EXE; and test -x "$CONDA_EXE"
        set -f conda_exe $CONDA_EXE
    else
        for prefix in /opt/homebrew/Caskroom/miniconda/base /opt/homebrew/Caskroom/anaconda/base \
            $HOME/miniconda3 $HOME/.miniconda3 $HOME/anaconda3 $HOME/.anaconda3 \
            $HOME/miniforge3 $HOME/mambaforge /opt/conda
            if test -x $prefix/bin/conda
                set -f conda_exe $prefix/bin/conda
                break
            end
        end
    end

    if not set -q conda_exe
        echo "conda: executable not found" >&2
        return 127
    end

    # pure already renders $CONDA_DEFAULT_ENV, so stop conda from wrapping
    # fish_prompt/fish_right_prompt with its own env indicator.
    set -gx CONDA_DISABLE_FISH_PROMPT true

    set -l hook ($conda_exe shell.fish hook)
    or begin
        echo "conda: shell hook failed ($conda_exe)" >&2
        return 1
    end
    string join \n $hook | source
end

function conda --description "Lazy-load conda, then run it"
    __conda_lazy_init; or return $status
    conda $argv
end

# No completion stub needed: fish ships its own conda completions, which are
# richer than the hook's and work without loading it.

status is-interactive; or return

# `conda init` auto-activates base, which is the only source of bare
# `python`/`pip` here. Keep them working without paying for the hook up front;
# if anything else already provides them (venv, mise), defer to that.
for cmd in python pip
    function $cmd --inherit-variable cmd --description "Lazy-load conda base, then run $cmd"
        functions -e $cmd
        if not command -q $cmd
            __conda_lazy_init; or return $status
        end
        command $cmd $argv
    end
end
