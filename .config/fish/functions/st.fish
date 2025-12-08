function st --description "SSH then launch Tmux"
    ssh -t $argv[1] "bash -l -c 'tmux attach || tmux'"
end
