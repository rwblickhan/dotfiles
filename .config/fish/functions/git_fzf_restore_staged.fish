function git_fzf_restore_staged
    git diff --name-only --cached | fzf -m | xargs git restore --staged
end