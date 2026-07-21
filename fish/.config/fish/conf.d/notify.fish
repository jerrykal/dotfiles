status is-interactive; or return
type -q notify; or return

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

    # Empty line (bare Enter) fires postexec too — nothing to report.
    set -l cmd (string trim -- $argv[1])
    test -n "$cmd"; or return

    # Skip interactive programs: match the first bare word, after stripping any
    # leading VAR=val assignments and a `sudo`/`command`/`env` wrapper.
    set -l words (string split -n ' ' -- $cmd)
    while set -q words[1]; and string match -qr '^\w+=' -- $words[1]
        set -e words[1]
    end
    while set -q words[1]; and contains -- $words[1] sudo command env builtin
        set -e words[1]
    end
    set -q words[1]; and contains -- $words[1] $notify_skip; and return

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
