function rgf
    rg --files-with-matches $argv | fzf --preview-window=wrap --preview "rg --color=always $argv {}"
end
