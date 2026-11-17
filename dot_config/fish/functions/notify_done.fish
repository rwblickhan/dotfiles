function notify_done --description "Notify that the preceding command finished"
    set -l last_status $status

    set -l message Done!
    if test (count $argv) -gt 0
        set message $argv
    end

    set -l cmdline (status current-commandline | string collect)
    set -l title (string replace -r '\s*(&&|\|\||;|&|\|)?\s*(and\s+|or\s+)?notify_done\b.*$' '' -- $cmdline | string trim)

    if test "$TERM_PROGRAM" = rex
        set -l state done
        test $last_status -ne 0; and set state error
        rex_status -t "$title" $state $message
    else if test -n "$title"
        notify -t "$title" $message
    else
        notify $message
    end

    return $last_status
end
