function git_fzf_restore_staged_worktree
    set files (git diff --name-only --cached)
    if test (count $files) -gt 0
        set selected_files (printf '%s\n' $files | fzf -m --preview="echo {} | xargs git diff --staged | delta")
        git restore --staged --worktree $selected_files
    else
        echo "No staged changes found"
    end
end
