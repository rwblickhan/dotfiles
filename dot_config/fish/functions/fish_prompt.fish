function fish_prompt
    set -l last_status $status
    set -l vcs
    set -l stat
    set -l pwd

    if contains -- --final-rendering $argv
        set pwd (path basename $PWD)
    else
        set pwd (prompt_pwd)
        set vcs (jj_prompt)
        if test $last_status -ne 0
            set stat ' ❌'
        end
    end

    if set -q ZMX_SESSION
        echo -n "[$ZMX_SESSION]"
    end
    # https://www.reasonable.work/colors/
    # cerulean 2
    set_color --bold 0092c5
    echo -n $pwd
    set_color normal
    echo -n $vcs
    echo -n $stat

    echo
    echo -n 'λ '
end
