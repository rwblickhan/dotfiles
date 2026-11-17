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

        set -l fields state=$state app=fish
        set -l msg (string join ' ' $message | string replace -ra '[\x00-\x1f\x7f-\x9f]' ' ' | string shorten -m 512)
        set -a fields msg=(printf '%s' $msg | base64 | string join '')
        if test -n "$title"
            set title (string replace -ra '[\x00-\x1f\x7f-\x9f]' ' ' -- $title | string shorten -m 60)
            set -a fields title=(printf '%s' $title | base64 | string join '')
        end

        set -l seq \e"]7501;"(string join : $fields)\e\\
        if test -t 2
            printf '%s' $seq >&2
        else if test -t 1
            printf '%s' $seq
        else if status is-interactive
            printf '%s' $seq >/dev/tty
        end
    else if test -n "$title"
        notify -t "$title" $message
    else
        notify $message
    end

    return $last_status
end
