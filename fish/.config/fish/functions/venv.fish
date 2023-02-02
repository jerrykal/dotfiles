function venv --description "Activate or create a python venv"
    # Check if a name is provided or else defaults to .venv
    if test -z "$argv[1]"
        set venv_name ".venv"
    else
        set venv_name "$argv[1]"
    end

    # Create a venv with the given name if one does not exist already
    if not test -e "./$venv_name/bin/activate.fish"
        python3 -m venv $venv_name
    end

    # Activate the venv
    source "./$venv_name/bin/activate.fish"
end
