function st --description "SSH then launch Tmux"
    sshr -t $argv[1] "bash -l -c '~/.config/tmux/scripts/session-picker.sh $argv[2]'"
end
