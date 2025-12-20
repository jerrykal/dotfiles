function conda --description "Lazy load conda"
    functions -e conda

    # Looking for conda executable
    set -l conda_paths /opt/homebrew/Caskroom/miniconda/base/ $HOME/.miniconda3 $HOME/miniconda3 /opt/homebrew/Caskroom/anaconda/base/ $HOME/.anaconda3 $HOME/anaconda3
    for path in $conda_paths
        if test -e "$path/bin/conda"
            set -f __conda_executable "$path/bin/conda"
            break
        end
    end
    if not set -q __conda_executable
        echo "`conda` executable not found."
        return 1
    end

    eval command $__conda_executable "shell.fish" hook | source

    function __conda_add_prompt
    end

    conda $argv
end
