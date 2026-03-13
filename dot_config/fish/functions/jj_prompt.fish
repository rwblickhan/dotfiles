function jj_prompt
    if jj root --quiet 2>/dev/null 1>/dev/null
        set jj_data (jj log -r @ --no-graph -T 'empty ++ "\n" ++ description.first_line() ++ "\n" ++ local_bookmarks' 2>/dev/null)
        set jj_lines (string split "\n" $jj_data)
        set jj_empty $jj_lines[1]
        set jj_desc $jj_lines[2]
        set jj_bm $jj_lines[3]

        # jj green
        set_color --bold bcc95f
        if test "$jj_empty" = true
            echo -n " (empty)"
        end
        if test -z "$jj_desc"
            echo -n " (no description set)"
        else
            echo -n " $jj_desc"
        end
        set_color normal

        if test -n "$jj_bm"
            echo -n " on "
            # jj purple
            set_color --bold bc99d4
            echo -n $jj_bm
            set_color normal
        end
    else
        echo -n (fish_git_prompt)
    end
end
