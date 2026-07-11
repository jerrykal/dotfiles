function st --description "SSH then launch Tmux"
    ssh -t $argv[1] "bash -l -c '~/.tmux/scripts/session-picker.sh $argv[2]'"
end
