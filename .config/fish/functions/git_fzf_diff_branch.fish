function git_fzf_diff_branch
    git diff $(git_fzf_branch_select) HEAD
end
