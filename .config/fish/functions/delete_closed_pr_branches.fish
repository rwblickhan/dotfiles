function delete_closed_pr_branches
    # Check if gh is installed
    if not command -v gh &>/dev/null
        echo "Error: GitHub CLI (gh) is not installed"
        echo "Install from: https://cli.github.com/"
        return 1
    end

    # Check if we're in a git repository
    if not git rev-parse --git-dir &>/dev/null
        echo "Error: Not in a git repository"
        return 1
    end

    echo "Checking local branches..."
    
    # Get list of all local branches (excluding current branch indicator)
    set local_branches (git branch --format='%(refname:short)')
    
    if test (count $local_branches) -eq 0
        echo "No local branches found"
        return 0
    end

    echo "Found "(count $local_branches)" local branch(es)"
    echo ""
    
    # Get current branch
    set current_branch (git branch --show-current)
    
    # Track statistics
    set deleted_count 0
    set skipped_count 0
    set no_pr_count 0

    # Iterate through local branches
    for branch in $local_branches
        # Skip current branch
        if test "$branch" = "$current_branch"
            echo (set_color yellow)"⊘ Skipping '$branch' (currently checked out)"(set_color normal)
            set skipped_count (math $skipped_count + 1)
            continue
        end

        # Check if branch has attached workflows
        set workflow_count (gh run list --branch $branch --limit 1 --json status --jq 'length' 2>/dev/null)
        if test "$workflow_count" -gt 0
            echo (set_color yellow)"⊘ Skipping '$branch' (has attached workflow)"(set_color normal)
            set skipped_count (math $skipped_count + 1)
            continue
        end

        # Check if branch has a PR and if it's closed
        set pr_state (gh pr list --state all --head $branch --json state --jq '.[0].state' 2>/dev/null)

        if test -z "$pr_state"
            # No PR found for this branch
            echo (set_color yellow)"⊘ Skipping '$branch' (no PR found)"(set_color normal)
            set no_pr_count (math $no_pr_count + 1)
            continue
        end

        if test "$pr_state" = "CLOSED" -o "$pr_state" = "MERGED"
            # Delete the branch
            if git branch -D $branch 2>/dev/null
                echo (set_color green)"✓ Deleted branch '$branch' (PR state: $pr_state)"(set_color normal)
                set deleted_count (math $deleted_count + 1)
            else
                echo (set_color red)"✗ Failed to delete branch '$branch'"(set_color normal)
            end
        end
    end

    # Print summary
    echo ""
    echo "Summary:"
    echo "  Deleted: $deleted_count"
    echo "  Skipped: $skipped_count"
    echo "  No PR found: $no_pr_count"
end
