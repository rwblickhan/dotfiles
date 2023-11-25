function git_fzf_restore_staged
    set files (git diff --name-only --cached)
    if test (count $files) -gt 0
        printf '%s\n' $files | fzf -m | xargs git restore --staged
    else
        echo "No staged changes found"
    end
end