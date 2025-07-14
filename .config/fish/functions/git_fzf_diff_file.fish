function git_fzf_diff_file
    set files (git diff --name-only HEAD)
    if test (count $files) -gt 0
        set selected_files (printf '%s\n' $files | fzf -m --preview="echo {} | xargs git diff HEAD | delta")
        git diff HEAD $selected_files
    else
        echo "No changes found"
    end
end
