function git_commit_all_message_push
    read -p "set_color green; echo 'Commit message?'; set_color normal; echo '> '" message
    git add -A && git commit -m "$message" && git push
end
