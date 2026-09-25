function sshr --wraps ssh --description "ssh that reconnects on a dropped link"
    set -l delay 2
    set -l first 1
    while true
        set -l start (date +%s)
        command ssh $argv
        set -l code $status
        set -l lasted (math (date +%s) - $start)
        # 255 = ssh itself failed; anything else is the remote's own exit
        test $code -eq 255; or return $code
        # a fast failure on the first try is a typo/auth/DNS error, not a drop
        if test $first -eq 1; and test $lasted -lt 10
            return $code
        end
        set first 0
        # a session that held for a while resets the backoff
        test $lasted -ge 60; and set delay 2
        echo "sshr: connection lost, retrying in "$delay"s…" >&2
        sleep $delay; or return
        set delay (math "min($delay * 2, 30)")
    end
end
