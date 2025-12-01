function _init_fisher --description "Setup fisher with alternative install path"
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

    if test -z "$fisher_path" || test "$fisher_path" = "$__fish_config_dir"
        exit
    end

    for file in $fisher_path/conf.d/*.fish
        source $file
    end
end
