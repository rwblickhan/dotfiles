function git_fzf_branch_select
    git for-each-ref --color=always --sort=-committerdate refs/heads/ --format='%(color:bold)%(HEAD)%(color:reset) %(color:blue)%(refname:short)%(color:reset)' | fzf --ansi --preview="echo {} | cut -c 3- | cut -d ' ' -f1 | xargs git log --color=always" | cut -c 3- | cut -d ' ' -f 1
end
