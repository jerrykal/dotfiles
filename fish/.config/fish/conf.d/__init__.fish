# Activate mise here so mise-managed tools are on PATH before other conf.d
# snippets run. mise lives in ~/.local/bin (official installer), which
# shell/.profile puts on PATH; MISE_FISH_AUTO_ACTIVATE is off so any vendor
# activate snippet does not run a redundant second activation.
if type -q mise
    set -gx MISE_FISH_AUTO_ACTIVATE 0
    mise activate fish | source
end

# Setup alternative install path for fisher plugins
set -gx fisher_path $__fish_config_dir/fisher

set fish_complete_path $fish_complete_path[1] $fisher_path/completions $fish_complete_path[2..]
set fish_function_path $fish_function_path[1] $fisher_path/functions $fish_function_path[2..]

# Automatically install fisher
if not test -d $fisher_path
    functions -e fisher &>/dev/null
    mkdir -p $fisher_path
    curl -sL https://git.io/fisher | source
    if test -s $__fish_config_dir/fish_plugins
        fisher update
    else
        fisher install jorgebucaran/fisher
    end
end

if test -d $fisher_path/conf.d
    for file in $fisher_path/conf.d/*.fish
        source $file
    end
end
