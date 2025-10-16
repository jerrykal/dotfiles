set -x PYTHONNOUSERSITE 1

# Looking for conda executable
set -l conda_paths /opt/homebrew/Caskroom/miniconda/base/ $HOME/.miniconda3 $HOME/miniconda3 /opt/homebrew/Caskroom/anaconda/base/ $HOME/.anaconda3 $HOME/anaconda3
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
alias conda="__lazy_load_conda && conda"

# Set up abbreviations
abbr -a ca conda activate
abbr -a cda conda deactivate
abbr -a ci conda install
abbr -a ccr conda create
abbr -a ce conda env
abbr -a cee conda env export
abbr -a cec conda env create
abbr -a cer conda env remove
abbr -a cel conda env list
abbr -a cl conda list
abbr -a cr conda remove