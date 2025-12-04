if not type -q fish
    return
end

fzf --fish | source

set -gx FZF_DEFAULT_OPTS "\
--layout reverse \
--bind 'ctrl-u:preview-page-up,ctrl-d:preview-page-down' \
--color=fg:#908caa,bg:#191724,hl:#ebbcba \
--color=fg+:#e0def4,bg+:#26233a,hl+:#ebbcba \
--color=border:#403d52,header:#31748f,gutter:#191724 \
--color=spinner:#f6c177,info:#9ccfd8 \
--color=pointer:#c4a7e7,marker:#eb6f92,prompt:#908caa"

if type -q bat
    set -l fzf_bat_cmd "bat -n --color=always {}"

    if type -q eza
        set -l fzf_eza_cmd "eza -a1 --group-directories-first --color=always {}"

        set -gx FZF_CTRL_T_OPTS "--preview 'if test -d {}; $fzf_eza_cmd; else; $fzf_bat_cmd; end'"
        set -gx FZF_ALT_C_OPTS "--preview '$fzf_eza_cmd'"
    else
        set -gx FZF_CTRL_T_OPTS "--preview '$fzf_bat_cmd'"
    end
end
