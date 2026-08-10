function notify --description "Send an OSC 777 desktop notification"
    argparse t/title= -- $argv
    or return 1

    if test (count $argv) -eq 0
        echo "Usage: notify [-t title] <message>" >&2
        return 1
    end

    set -q _flag_title[1]
    or set _flag_title (prompt_hostname)

    set -l title (string replace -ra '[\x01-\x1f\x7f-\x9f;]' ' ' -- "$_flag_title")
    set -l body (string replace -ra '[\x01-\x1f\x7f-\x9f]' ' ' -- (string join ' ' $argv))
    set -l seq \e"]777;notify;$title;$body"\a

    if test -t 2
        printf '%s' $seq >&2
    else if test -t 1
        printf '%s' $seq
    else if status is-interactive
        printf '%s' $seq >/dev/tty
    end
end
