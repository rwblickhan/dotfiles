function git_commit_all_message_push
    git add -A && git commit -m "$argv" && git push
end
