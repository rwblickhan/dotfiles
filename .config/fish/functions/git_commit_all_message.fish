function git_commit_all_message
    read message
    git add -A && git commit -m "$message" && git push
end
