status is-interactive; or return
command -q notify; or return

# Desktop notification when a long-running foreground command finishes, via the
# shared `notify` bin (OSC 777, tmux-aware) — the same mechanism Claude Code
# uses for its completion pings.
#
# Only commands whose runtime reaches $notify_min_duration seconds notify, so
# quick commands stay silent. Interactive programs in $notify_skip (editors,
# pagers, the shell itself) never notify however long they stay open. Both are
# plain global vars — override them in local.fish, or `set -e notify_min_duration`
# to disable entirely.
set -q notify_min_duration; or set -g notify_min_duration 10
set -q notify_skip; or set -g notify_skip nvim vim vi nano less more man ssh fish bash zsh tmux btop htop watch fg

function __notify_postexec --on-event fish_postexec
    set -l exit_code $status
    set -q notify_min_duration; or return

    # $CMD_DURATION is the just-finished command's runtime in ms.
    test "$CMD_DURATION" -ge (math "$notify_min_duration x 1000"); or return
    # 130 is Ctrl-C: whoever stopped it is already at the terminal.
    test $exit_code -eq 130; and return

    # Command substitution splits on newlines, so a multi-line command line
    # would arrive as several elements and shift the body out of notify's $2.
    # Flattening whitespace first keeps it a single argument.
    set -l cmd (string replace -ra '\s+' ' ' -- $argv[1] | string trim)
    test -n "$cmd"; or return

    # Skip interactive programs. Walk off leading VAR=val assignments and
    # sudo/command/env/time wrappers together — `env FOO=bar vim` interleaves
    # them — along with the options those wrappers take, then match on the
    # basename so /usr/bin/less counts as less. --tokenize honours quoting, so
    # an assignment like FOO="a b" stays one token.
    echo $cmd | read -lat words
    set -l opt_with_arg -u -g -U -C -p -h -r -t -T -R -n --user --group --chdir
    while set -q words[1]
        if string match -qr '^\w+=' -- $words[1]
            set -e words[1]
        else if contains -- $words[1] sudo doas command env builtin nice nohup time
            set -e words[1]
        else if test "$words[1]" = --
            set -e words[1]
            break
        else if string match -q -- '-*' $words[1]
            if contains -- $words[1] $opt_with_arg; and set -q words[2]
                set -e words[2]
            end
            set -e words[1]
        else
            break
        end
    end
    set -q words[1]; and contains -- (path basename -- $words[1]) $notify_skip; and return

    set -l secs (math -s0 "$CMD_DURATION / 1000")
    set -l dur
    if test $secs -ge 60
        set dur (printf '%dm%02ds' (math -s0 "$secs / 60") (math "$secs % 60"))
    else
        set dur "$secs"s
    end

    set -l mark ✓
    test $exit_code -eq 0; or set mark "✗ exit $exit_code"

    notify (string sub -l 60 -- $cmd) "$mark · $dur"
end
