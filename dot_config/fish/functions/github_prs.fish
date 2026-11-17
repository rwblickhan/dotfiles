function github_prs --description "Show my PRs in the current repo with draft, review, CI, and merge queue status"
    argparse 'R/repo=' 'w/watch=?' -- $argv
    or return

    set -l repo_args
    set -q _flag_repo; and set repo_args -R $_flag_repo
    set -l repo (gh repo view $repo_args --json nameWithOwner --jq .nameWithOwner)
    or return

    if not set -q _flag_watch
        set -l color plain
        isatty stdout; and set color color
        __github_prs_render $repo $color
        return
    end

    set -l interval 120
    test -n "$_flag_watch"; and set interval $_flag_watch
    if not string match -qr '^[1-9]\d*$' -- $interval
        echo "github_prs: --watch interval must be a positive number of seconds" >&2
        return 1
    end

    while true
        set -l output (__github_prs_render $repo color 2>&1)
        clear
        printf '%s\n' $output
        echo
        printf '%sUpdated %s · every %ss · Ctrl-C to stop%s\n' (set_color brblack) (date +%H:%M:%S) $interval (set_color normal)
        sleep $interval
    end
end

function __github_prs_render --argument-names repo color
    set -l queue (gh api graphql -f q="repo:$repo is:pr is:open author:@me" -f query='query($q: String!) {
        search(query: $q, type: ISSUE, first: 100) { nodes { ... on PullRequest { number mergeQueueEntry { position } } } }
    }' --jq '.data.search.nodes[] | "#\(.number)\t\(.mergeQueueEntry.position // "")"')
    or return

    set -l tsv (gh pr status -R $repo --json number,title,isDraft,reviewDecision,statusCheckRollup --jq '.createdBy[] | [
        "#\(.number)",
        (if .isDraft then "DRAFT" else "READY" end),
        (.reviewDecision // "" | if . == "" then "NO_REVIEW" else . end),
        ([.statusCheckRollup[] | (.conclusion // "") as $c | if $c != "" then $c else (.state // "PENDING") end | select(. != "CANCELLED" and . != "SKIPPED" and . != "NEUTRAL")]
            | if length == 0 then "NO_CHECKS"
            elif any(.[]; . == "FAILURE" or . == "ERROR" or . == "TIMED_OUT" or . == "ACTION_REQUIRED") then "FAILING"
            elif any(.[]; . == "PENDING" or . == "EXPECTED") then "PENDING"
            else "PASSING" end),
        .title
    ] | @tsv')
    or return

    set -l tab (printf '\t')
    set -l rows (for line in $tsv
            set -l fields (string split $tab -- $line)
            set -l position (string match -r "^$fields[1]$tab(\d+)\$" -- $queue)[2]
            set -l q -
            test -n "$position"; and set q "Q$position"
            string join $tab -- $fields[1..4] $q $fields[5..]
        end | column -t -s $tab)

    if test "$color" != color
        printf '%s\n' $rows
        return
    end

    for row in $rows
        set -l f (string match -r '^(\S+)(\s+)(\S+)(\s+)(\S+)(\s+)(\S+)(\s+)(\S+)(.*)$' -- $row)
        printf '%s' \
            (set_color cyan) $f[2] (set_color normal) $f[3] \
            (__github_prs_color $f[4]) $f[5] \
            (__github_prs_color $f[6]) $f[7] \
            (__github_prs_color $f[8]) $f[9] \
            (__github_prs_color $f[10]) $f[11]
        echo
    end
end

function __github_prs_color
    switch $argv[1]
        case PASSING APPROVED READY
            set_color green
        case PENDING REVIEW_REQUIRED
            set_color yellow
        case FAILING CHANGES_REQUESTED
            set_color red
        case 'Q*'
            set_color magenta
        case '*'
            set_color brblack
    end
    printf '%s%s' $argv[1] (set_color normal)
end
