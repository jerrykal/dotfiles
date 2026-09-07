function wtf --description "diagnose the last failed command" --wraps wtf
    set -l last $status
    command wtf $last $argv
end
