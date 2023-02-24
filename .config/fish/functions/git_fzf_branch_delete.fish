function git_fzf_branch_delete
    git branch -d $(git_fzf_branch_select)
end
