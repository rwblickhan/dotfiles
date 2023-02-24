function git_fzf_diff
    git diff $(git_fzf_branch_select) HEAD
end
