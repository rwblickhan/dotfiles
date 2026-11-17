function rex_status --description "Report program status to Rex via OSC 7501"
    argparse t/title= -- $argv
    or return 1

    if test (count $argv) -eq 0
        echo "Usage: rex_status [-t title] <state> [message]" >&2
        return 1
    end

    set -l fields state=$argv[1] app=fish
    set -l msg (string join ' ' -- $argv[2..] | string replace -ra '[\x00-\x1f\x7f-\x9f]' ' ' | string shorten -m 512)
    if test -n "$msg"
        set -a fields msg=(printf '%s' $msg | base64 | string join '')
    end
    if set -q _flag_title[1]; and test -n "$_flag_title"
        set -l title (string replace -ra '[\x00-\x1f\x7f-\x9f]' ' ' -- $_flag_title | string shorten -m 60)
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
end
