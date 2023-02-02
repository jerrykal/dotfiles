function __auto_source_venv --on-variable PWD --description "Activate/Deactivate virtualenv on directory change"
    status --is-command-substitution; and return

    # Search parent directories up until the home root for venv activation script
    set curr_dir "$PWD"
    while string match -qr "$HOME/*" "$curr_dir"
        if test -e "$curr_dir/.venv/bin/activate.fish"
            if test "$curr_dir/.venv" != "$VIRTUAL_ENV"
                source "$curr_dir/.venv/bin/activate.fish"
            end
            return 0
        end
        set curr_dir (dirname "$curr_dir")
    end

    if not test -z "$VIRTUAL_ENV"
        deactivate
    end
end

# Call on startup
__auto_source_venv
