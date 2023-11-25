function git_fzf_restore
    set files (git diff --name-only)
    if test (count $files) -gt 0
        printf '%s\n' $files | fzf -m | xargs git restore
    else
        echo "No unstaged changes found"
    end
end