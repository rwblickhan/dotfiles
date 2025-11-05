function git_fzf_diff_branch_name_only
    git diff $(git_fzf_branch_select) HEAD --name-only
end
