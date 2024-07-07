function rfv --description 'rg tui built with fzf and bat'
    # https://github.com/junegunn/fzf/blob/master/ADVANCED.md#using-fzf-as-the-secondary-filter
    rg --auto-hybrid-regex --smart-case --hidden --color=always --line-number --no-heading "$argv" |
        fzf -m --ansi \
            --color 'hl:-1:underline,hl+:-1:underline:reverse' \
            --delimiter ':' \
            --preview "bat --color=always {1} --theme='Solarized (light)' --highlight-line {2}" \
            --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' \
            --bind "enter:become(code_demux {+1..2})"
end
