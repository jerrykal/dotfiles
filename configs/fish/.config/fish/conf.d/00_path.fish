function add_path_if_exists
    if test -d $argv[1]
        fish_add_path -g $argv[1]
    end
end

add_path_if_exists $HOME/.local/bin
add_path_if_exists $HOME/.cargo/bin
add_path_if_exists /opt/homebrew/bin