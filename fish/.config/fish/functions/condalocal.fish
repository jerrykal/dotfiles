function condalocal --description "Set conda environment for the current working directory"
    set envfile ".condaenv"
    if test (count $argv) -eq 0
        if not set -q CONDA_DEFAULT_ENV
            echo -e "ERROR: No conda environment is currently active. Please call this function with a conda environment activated, or pass a name of the desired environment as argument"
            return 1
        end
        echo $CONDA_DEFAULT_ENV > $envfile
    else
        echo $argv[1] > $envfile
        if not set -q CONDA_DEFAULT_ENV
            __auto_activate_conda_env
        end
    end
end
