function __goodlinks_thin_print_item --description "Print details for one GoodLinks article"
    set -l index $argv[1]
    set -l count $argv[2]
    set -l title $argv[3]
    set -l url $argv[4]
    set -l author $argv[5]
    set -l tags $argv[6]
    set -l summary $argv[7]
    set -l read_at $argv[8]
    set -l added_at $argv[9]
    set -l tag $argv[10]

    echo ""
    if test -n "$tag"
        echo "[$index/$count] $title  $tag"
    else
        echo "[$index/$count] $title"
    end
    echo "  URL:    $url"
    if test -n "$author"
        echo "  Author: $author"
    end
    if test -n "$tags"
        echo "  Tags:   $tags"
    end
    if test -n "$summary"
        echo "  Summary: $summary"
    end
    if test -n "$read_at"
        echo "  Read:   $read_at"
    end
    if test -n "$added_at"
        echo "  Added:  $added_at"
    end
end

function __goodlinks_thin_process --description "Fetch, review in two passes, and delete a random sample of GoodLinks articles"
    set -l token $argv[1]
    set -l base $argv[2]
    set -l read_filter $argv[3]
    set -l sample_size $argv[4]
    set -l label $argv[5]
    set -l allowlist_domains $argv[6..-1]

    set -l allowlist_json (jq -n --args '$ARGS.positional | map(ascii_downcase)' -- $allowlist_domains)

    set -l limit 1000
    set -l offset 0
    set -l tmpfile (mktemp)
    set -l allfile (mktemp)

    echo "Fetching $label articles..."

    while true
        xh --ignore-stdin --json GET "$base/links" \
            "Authorization:Bearer $token" \
            "read==$read_filter" \
            starred==false \
            highlighted==false \
            "limit==$limit" \
            "offset==$offset" \
            sort==newestRead > $tmpfile 2>/dev/null
        if test $status -ne 0
            echo "Error: request failed (is GoodLinks running?)" >&2
            rm -f $tmpfile $allfile
            return 1
        end

        jq -c --argjson allowlist "$allowlist_json" '
            def norm: (. // "") | ascii_downcase | sub("^https?://"; "") | sub("[?#].*$"; "");
            .data[]
            | select((.highlighted // false | not) and (.starred // false | not))
            | (.url | norm) as $full
            | ($full | sub("/.*$"; "")) as $host
            | select(
                ($allowlist | any(. as $e |
                    if ($e | test("/")) then ($full == $e or ($full | startswith($e + "/")))
                    else $host == $e
                    end
                )) | not
              )
        ' $tmpfile >> $allfile

        set -l has_more (jq -r '.hasMore // false' $tmpfile)
        if test "$has_more" != true
            break
        end
        set offset (math $offset + $limit)
    end
    rm -f $tmpfile

    set -l total (wc -l < $allfile | string trim)
    echo "Found $total $label articles. Picking $sample_size at random..."

    set -l selected (python3 -c "
import sys, json, random
lines = [l for l in sys.stdin.read().strip().split('\n') if l]
random.shuffle(lines)
for line in lines[:$sample_size]:
    print(line)
" < $allfile)
    rm -f $allfile

    # Pass 1: quick triage. y = mark for deletion, n = keep, o = open in
    # browser and defer the decision to pass 2, q = stop early.
    set -l marked_ids
    set -l marked_titles
    set -l marked_urls
    set -l marked_authors
    set -l marked_tags

    set -l opened_ids
    set -l opened_titles
    set -l opened_urls
    set -l opened_authors
    set -l opened_tags

    set -l count (count $selected)
    set -l quit_early false

    for i in (seq 1 $count)
        set -l link $selected[$i]
        set -l id (echo $link | jq -r '.id')
        set -l title (echo $link | jq -r '.title // ""')
        set -l url (echo $link | jq -r '.url')
        set -l author (echo $link | jq -r '.author // ""')
        set -l tags (echo $link | jq -r '(.tags // []) | if type == "array" then join(", ") else . end')
        set -l summary (echo $link | jq -r '.summary // ""')
        set -l read_at (echo $link | jq -r '.readAt // ""')
        set -l added_at (echo $link | jq -r '.addedAt // ""')

        if test -z "$title"
            set title "(no title)"
        end

        __goodlinks_thin_print_item $i $count $title $url $author $tags $summary $read_at $added_at ""

        set -l answer ""
        while true
            read -l -P "  Delete (y), keep (n), open for later review (o), or quit (q)? [y/n/o/q] " answer
            switch $answer
                case y Y
                    set -a marked_ids $id
                    set -a marked_titles $title
                    set -a marked_urls $url
                    set -a marked_authors $author
                    set -a marked_tags $tags
                    echo "  → Marked for deletion"
                    break
                case n N
                    echo "  → Keeping"
                    break
                case o O
                    open $url
                    set -a opened_ids $id
                    set -a opened_titles $title
                    set -a opened_urls $url
                    set -a opened_authors $author
                    set -a opened_tags $tags
                    echo "  → Opened; will revisit in review pass"
                    break
                case q Q
                    set quit_early true
                    break
                case '*'
                    echo "  Please enter y, n, o, or q"
            end
        end

        if test "$quit_early" = true
            echo "Quitting early."
            break
        end
    end

    set -l review_ids $marked_ids $opened_ids
    set -l review_titles $marked_titles $opened_titles
    set -l review_urls $marked_urls $opened_urls
    set -l review_authors $marked_authors $opened_authors
    set -l review_tags $marked_tags $opened_tags
    set -l review_count (count $review_ids)

    if test $review_count -eq 0
        echo ""
        echo "No $label articles marked for deletion or opened for review."
        return 0
    end

    # Pass 2: revisit everything opened and/or marked for deletion in pass 1.
    set -l final_ids
    set -l final_titles
    set -l final_urls
    set -l final_authors
    set -l quit_early false

    for i in (seq 1 $review_count)
        set -l id $review_ids[$i]
        set -l title $review_titles[$i]
        set -l url $review_urls[$i]
        set -l author $review_authors[$i]
        set -l tags $review_tags[$i]
        set -l tag "(marked for deletion)"
        if contains -- $id $opened_ids
            set tag "(opened)"
        end

        __goodlinks_thin_print_item $i $review_count $title $url $author $tags "" "" "" $tag

        set -l answer ""
        while true
            read -l -P "  Delete (y), keep (n), or quit review (q)? [y/n/q] " answer
            switch $answer
                case y Y
                    set -a final_ids $id
                    set -a final_titles $title
                    set -a final_urls $url
                    set -a final_authors $author
                    echo "  → Marked for deletion"
                    break
                case n N
                    echo "  → Keeping"
                    break
                case q Q
                    set quit_early true
                    break
                case '*'
                    echo "  Please enter y, n, or q"
            end
        end

        if test "$quit_early" = true
            echo "Quitting review early."
            break
        end
    end

    set -l final_count (count $final_ids)
    if test $final_count -eq 0
        echo ""
        echo "No $label articles marked for deletion."
        return 0
    end

    if test -z "$EDITOR"
        echo "goodlinks_thin: \$EDITOR is not set" >&2
        return 1
    end

    set -l reviewfile (mktemp /tmp/goodlinks_thin.XXXXXX)
    echo "# goodlinks_thin — $label articles queued for deletion — save and close to confirm" > $reviewfile
    echo "# Comment out (or delete) a \"delete <id>\" line to UNDELETE that article." >> $reviewfile
    echo >> $reviewfile

    for i in (seq 1 $final_count)
        set -l title_line $final_titles[$i]
        if test -n "$final_authors[$i]"
            set title_line "$title_line — $final_authors[$i]"
        end
        echo "# $title_line" >> $reviewfile
        echo "delete $final_ids[$i]" >> $reviewfile
    end

    eval $EDITOR (string escape $reviewfile)

    set -l confirmed_ids
    set -l confirmed_titles
    set -l confirmed_urls

    for line in (cat $reviewfile)
        set -l trimmed (string trim $line)
        set -l m (string match -r '^delete\s+(\S+)$' -- $trimmed)
        if test (count $m) -eq 2
            set -l idx (contains -i -- $m[2] $final_ids)
            if test -n "$idx"
                set -a confirmed_ids $final_ids[$idx]
                set -a confirmed_titles $final_titles[$idx]
                set -a confirmed_urls $final_urls[$idx]
            end
        end
    end
    rm -f $reviewfile

    set -l confirmed_count (count $confirmed_ids)
    if test $confirmed_count -eq 0
        echo ""
        echo "No $label articles marked for deletion."
        return 0
    end

    echo ""
    echo "Deleting $confirmed_count $label article(s):"
    for i in (seq 1 $confirmed_count)
        echo "  - $confirmed_titles[$i]"
        echo "    $confirmed_urls[$i]"
    end

    set -l id_params
    for id in $confirmed_ids
        set -a id_params "id==$id"
    end

    set -l deltmp (mktemp)
    xh --ignore-stdin --check-status DELETE "$base/links" \
        "Authorization:Bearer $token" $id_params > $deltmp 2>&1
    if test $status -ne 0
        echo "Error: deletion request failed" >&2
        cat $deltmp >&2
        rm -f $deltmp
        return 1
    end
    rm -f $deltmp

    echo ""
    echo "Done. $confirmed_count $label article(s) deleted."
end

function goodlinks_thin --description "Interactively thin out old read GoodLinks articles"
    argparse 'h/help' -- $argv
    or return 1

    if set -q _flag_help
        echo "Usage: goodlinks_thin"
        echo ""
        echo "Fetches all read GoodLinks articles, picks 50 at random, and does"
        echo "two review passes. Pass 1: for each article, mark for deletion (y),"
        echo "keep (n), open in browser and defer the decision (o), or quit (q)."
        echo "Pass 2: revisit every article that was opened and/or marked for"
        echo "deletion in pass 1, and mark (y) or unmark (n) it for deletion."
        echo "Then opens \$EDITOR with a review file listing every article still"
        echo "marked for deletion — comment out a \"delete <id>\" line there to"
        echo "undelete that article — and deletes whatever remains once you save"
        echo "and close. Favorited and highlighted links are never included."
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

    set -l base "http://localhost:9428/api/v1"

    # Domains that should never be offered for deletion, even if sampled.
    set -l allowlist_domains dynomight.substack.com blog.ayjay.org v5.chriskrycho.com www.robinsloan.com www.futilitycloset.com buttondown.email/hillelwayne twitter.com/BretDevereaux acoup.blog www.atvbt.com maya.land bsky.app/profile/bretdevereaux.bsky.social www.blackbirdspyplane.com www.hillelwayne.com www.scattered-thoughts.net www.reddit.com/r/AskHistorians borretti.me resobscura.substack.com

    __goodlinks_thin_process $token $base true 50 read $allowlist_domains
    or return 1
end
