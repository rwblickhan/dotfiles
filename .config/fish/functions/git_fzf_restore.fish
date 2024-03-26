function git_fzf_restore
    set files (git diff --name-only)
    if test (count $files) -gt 0
        set selected_files (printf '%s\n' $files | fzf -m --preview="echo \"{}\" | xargs git diff | delta")
        git restore $selected_files
    else
        echo "No unstaged changes found"
    end
end
