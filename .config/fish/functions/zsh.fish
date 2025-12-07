function zsh --wraps zsh
    SKIP_FISH=1 command zsh $argv
end
