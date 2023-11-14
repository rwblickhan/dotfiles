function git_fzf_restore
    git diff --name-only | fzf -m | xargs git restore
end