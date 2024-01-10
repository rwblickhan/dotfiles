function git_fzf_diff_file_staged
    set files (git diff --name-only HEAD)
    if test (count $files) -gt 0
        printf '%s\n' $files | fzf -m --preview="echo {} | xargs git diff HEAD | delta" | xargs git diff HEAD
    else
        echo "No changes found"
    end
end
