function st --description "SSH then launch Tmux"
    ssh -t $argv[1] "tmux attach || tmux"
end
