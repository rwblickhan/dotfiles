function git_fzf_commit_select_copy
    git l | fzf --reverse | choose 0 | pbcopy
end
