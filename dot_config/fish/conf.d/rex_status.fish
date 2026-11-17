status is-interactive; or return
test "$TERM_PROGRAM" = rex; or return

set -g rex_status_threshold_ms 5000
set -g rex_status_ignore vim nvim hx less man ssh mosh jjui lazygit fzf htop btop top claude

function __rex_status_postexec --on-event fish_postexec
    set -l last_status $status
    set -l cmdline (string trim -- $argv[1] | string collect)
    test -n "$cmdline"; or return
    test "$CMD_DURATION" -ge $rex_status_threshold_ms; or return
    string match -qr '\bnotify_done\b' -- $cmdline; and return
    set -l cmd (string split -n -f1 ' ' -- $cmdline)
    contains -- $cmd $rex_status_ignore; and return

    set -l secs (math --scale=0 $CMD_DURATION / 1000)
    set -l state done
    set -l msg "Finished in "$secs"s"
    if test $last_status -ne 0
        set state error
        set msg "Exited $last_status after "$secs"s"
    end
    rex_status -t $cmdline $state $msg
    notify -t $cmdline $msg
end
