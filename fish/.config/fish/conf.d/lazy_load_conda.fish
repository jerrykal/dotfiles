if not test -f $HOME/.miniconda3/bin/conda
    return
end

set __lazy_conda_aliases conda python pip
function __load_conda --description "Load conda on demand"
    # Erase the aliases so that __load_conda won't be called again
    functions --erase $__lazy_conda_aliases

    # Load conda
    eval $HOME/.miniconda3/bin/conda "shell.fish" "hook" | source

    # Erase the __load_conda function
    functions --erase __load_conda
end

for lazy_conda_alias in $__lazy_conda_aliases
    alias $lazy_conda_alias="__load_conda && $lazy_conda_alias"
end
