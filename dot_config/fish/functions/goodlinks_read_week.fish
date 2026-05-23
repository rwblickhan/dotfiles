function goodlinks_read_week --description "Output a markdown table of GoodLinks articles read in the past 7 days"
    argparse 'h/help' -- $argv
    or return 1

    if set -q _flag_help
        echo "Usage: goodlinks_read_week"
        echo ""
        echo "Outputs a markdown-formatted table of all GoodLinks articles marked"
        echo "as read in the past 7 days, with title and URL columns."
        echo ""
        echo "Options:"
        echo "  -h, --help    Show this help"
        return 0
    end

    set -l token (op read "op://Private/GoodLinks/token" 2>/dev/null)
    if test -z "$token"
        echo "Error: failed to load GoodLinks API key from 1Password" >&2
        return 1
    end

    set -l since (date -v-7d -u +%Y-%m-%dT%H:%M:%SZ)
    set -l base http://localhost:9428/api/v1
    set -l limit 1000
    set -l offset 0
    set -l tmpfile (mktemp)

    echo "| Title | URL |"
    echo "| --- | --- |"

    while true
        xh --ignore-stdin --json GET "$base/links" \
            "Authorization:Bearer $token" \
            read==true \
            "readAfter==$since" \
            "limit==$limit" \
            "offset==$offset" \
            sort==newestRead > $tmpfile 2>/dev/null
        if test $status -ne 0
            echo "Error: request failed (is GoodLinks running?)" >&2
            rm -f $tmpfile
            return 1
        end

        jq -r '.data[] | "| \(if (.title == null or .title == "") then .url else .title end) | \(.url) |"' $tmpfile

        set -l has_more (jq -r '.hasMore // false' $tmpfile)
        if test "$has_more" != true
            break
        end
        set offset (math $offset + $limit)
    end

    rm -f $tmpfile
end
