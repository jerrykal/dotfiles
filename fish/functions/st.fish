function st --description "SSH then launch Tmux"
    set -l cmd ssh
    if command -q autossh
        set cmd autossh -M 0
    end
    $cmd -t $argv[1] "bash -l -c '~/.config/tmux/scripts/session-picker.sh $argv[2]'"
end
