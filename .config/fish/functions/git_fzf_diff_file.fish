function git_fzf_diff_file
    set files (git diff --name-only)
    if test (count $files) -gt 0
        set selected_files (printf '%s\n' $files | fzf -m --preview="echo {} | xargs git diff | delta")
        git diff $selected_files
    else
        echo "No unstaged changes found"
    end
end
