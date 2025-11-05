function git_fzf_branch_delete
    git branch -D $(git_fzf_branch_multiselect)
end
