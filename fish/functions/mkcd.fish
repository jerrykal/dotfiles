function mkcd --description "mkdir then cd"
    mkdir -p -- $argv[1]; and cd -- $argv[1]
end
