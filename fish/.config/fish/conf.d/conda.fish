set -x PYTHONNOUSERSITE 1

# Looking for conda executable
set -l conda_paths /opt/homebrew/Caskroom/miniconda/base/ $HOME/.miniconda3 $HOME/miniconda3 $HOME/.anaconda3 $HOME/anaconda3
for path in $conda_paths
    if test -e "$path/bin/conda"
        set -g __conda_path $path
        break
    end
end

# Skip if conda is not installed
if not set -q __conda_path
    return
end


# Lazy load conda to speedup shell startup time
function __lazy_load_conda

    # Erase the aliases so that __lazy_load_conda won't be called again
    functions --erase $__lazy_conda_aliases

    # Load conda
    eval $__conda_path/bin/conda "shell.fish" "hook" | source
    set -e __conda_path

    # Erase the __lazy_load_conda function
    functions --erase __lazy_load_conda
end

# Setup aliases that will load conda before the calling the command if its not loaded already
set __lazy_conda_aliases conda python pip
for lazy_conda_alias in $__lazy_conda_aliases
    alias $lazy_conda_alias="__lazy_load_conda && $lazy_conda_alias"
end


# Activate conda environment if .condaenv is found
function __auto_activate_conda_env --on-variable PWD --on-event init_done

    # Do nothing if current conda env has been activated by the user manually
    if set -q __conda_activated_by_user
        return
    end

    set envfile ".condaenv"
    set currdir (pwd)

    # Look for .condaenv up until the HOME directory
    while string match -qr "$HOME/*" $currdir
        if test -f "$currdir/$envfile"
            set condaenv (cat "$currdir/$envfile")
            break
        end

        set currdir (dirname $currdir)
    end

    # Do nothing if no envfile is found
    if not set -q condaenv

        # Also deactivate conda environment if one is currently active
        if set -q CONDA_DEFAULT_ENV
            conda deactivate
        end

        return
    end

    # Do nothing if current active environment is the same as the one specified in the envfile
    if test "$condaenv" = "$CONDA_DEFAULT_ENV"; and not set -q VIM
        return
    end

    # Deactivate conda environment if one is currently active
    if set -q CONDA_DEFAULT_ENV
        conda deactivate
    end

    # Activate conda environment
    set -g __conda_activated_by_script
    conda activate $condaenv
end

# A hook that checks if conda activate is called by the user or by the script
function __conda_activate_hook --on-variable CONDA_DEFAULT_ENV
    if not set -q CONDA_DEFAULT_ENV
        set -e __conda_activated_by_user
        return
    end

    if not set -q __conda_activated_by_script
        set -g __conda_activated_by_user
    else
        set -e __conda_activated_by_script
    end
end
