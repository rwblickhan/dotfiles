function git_fzf_commit_select
    git l | fzf --reverse | choose 0
end
