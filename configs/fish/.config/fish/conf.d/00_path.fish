fish_add_path -P $HOME/.cargo/bin
fish_add_path -P $HOME/.local/bin
fish_add_path -P /opt/homebrew/bin

# Add linuxbrew to path if it exists
if test -x /home/linuxbrew/.linuxbrew/bin/brew
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
end
