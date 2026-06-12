function fish_user_key_bindings
    # Add this to disable fzf shift-tab completion
    bind shift-tab complete-and-search
    bind -M insert shift-tab complete-and-search
end
