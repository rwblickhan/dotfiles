function tmux_fzf_search
    set options urls files digits hashes double-quotes single-quotes parens
    set selection (printf '%s\n' $options | fzf)
    tmux copy-mode
    switch $selection
        case urls
            tmux send-keys -X search-backward '(https?://|git@|git://|ssh://|ftp://|file:///)[[:alnum:]?=%/_.:,;~@!#$&()*+-]*'
        case files
            tmux send-keys -X search-backward '(^|^\.|[[:space:]]|[[:space:]]\.|[[:space:]]\.\.|^\.\.)[[:alnum:]~_-]*/[][[:alnum:]_.#$%&+=/@-]*'
        case digits
            tmux send-keys -X search-backward '[[:digit:]]+'
        case hashes
            tmux send-keys -X search-backward '[0-9a-f]{7,40}|[[:alnum:]]{52}|[0-9a-f]{64}'
        case double-quotes
            tmux send-keys -X search-backward '"[^"]*"'
        case single-quotes
            tmux send-keys -X search-backward '\'[^\']*\''
        case parens
            tmux send-keys -X search-backward '\([^\)]*\)'
    end
end
