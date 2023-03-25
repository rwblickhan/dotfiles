function git_fzf_interactive_checkout
    git diff --name-only | fzf -m | xargs git checkout
end