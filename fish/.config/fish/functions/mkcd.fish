function mkcd --description "mkdir then cd"
    mkdir -p $argv[1]
    cd $argv[1]
end
