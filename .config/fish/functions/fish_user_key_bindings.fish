function fish_user_key_bindings
    # Enable vi mode and set the initial mode to insert
    fish_vi_key_bindings insert

    # Emacs-style bindings for insertion mode.
    # The `-M` flag specifies the mode.
    # The `\c` escape sequence is for the Ctrl key.
    bind -M insert \ca beginning-of-line
    bind -M insert \ce end-of-line
    bind -M insert \cb backward-char
    bind -M insert \cf forward-char
    bind -M insert \cp up-or-search
    bind -M insert \cn down-or-search
    bind -M insert \ck kill-whole-line
    bind -M insert \cw backward-kill-word

    # Emacs-style bindings for normal (default) mode.
    bind -M default \ca beginning-of-line
    bind -M default \ce end-of-line
    bind -M default \cb backward-char
    bind -M default \cf forward-char
end
