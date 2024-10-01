function git_fzf_merge
    git merge $(git_fzf_branch_select) --no-edit
end
