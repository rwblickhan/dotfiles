function __goodlinks_thin_process --description "Fetch, review via editor, and delete a random sample of GoodLinks articles"
    set -l token $argv[1]
    set -l base $argv[2]
    set -l read_filter $argv[3]
    set -l sample_size $argv[4]
    set -l label $argv[5]

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

        jq -c '.data[] | select((.highlighted // false | not) and (.starred // false | not))' $tmpfile >> $allfile

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

    set -l count (count $selected)
    if test $count -eq 0
        echo "No $label articles to review."
        return 0
    end

    if test -z "$EDITOR"
        echo "goodlinks_thin: \$EDITOR is not set" >&2
        return 1
    end

    set -l link_ids
    set -l link_titles
    set -l link_urls

    set -l reviewfile (mktemp /tmp/goodlinks_thin.XXXXXX)
    echo "# goodlinks_thin — $label articles — save and close to review" > $reviewfile
    echo "# Uncomment a \"delete <id>\" line for each article you want removed." >> $reviewfile
    echo >> $reviewfile

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

        set -a link_ids $id
        set -a link_titles $title
        set -a link_urls $url

        echo "# [$i/$count] $title" >> $reviewfile
        echo "#   URL:    $url" >> $reviewfile
        if test -n "$author"
            echo "#   Author: $author" >> $reviewfile
        end
        if test -n "$tags"
            echo "#   Tags:   $tags" >> $reviewfile
        end
        if test -n "$summary"
            echo "#   Summary: $summary" >> $reviewfile
        end
        if test -n "$read_at"
            echo "#   Read:   $read_at" >> $reviewfile
        end
        if test -n "$added_at"
            echo "#   Added:  $added_at" >> $reviewfile
        end
        echo "# delete $id" >> $reviewfile
        echo >> $reviewfile
    end

    eval $EDITOR (string escape $reviewfile)

    set -l to_delete_ids
    set -l to_delete_titles
    set -l to_delete_urls

    for line in (cat $reviewfile)
        set -l trimmed (string trim $line)
        set -l m (string match -r '^delete\s+(\S+)$' -- $trimmed)
        if test (count $m) -eq 2
            set -l idx (contains -i -- $m[2] $link_ids)
            if test -n "$idx"
                set -a to_delete_ids $link_ids[$idx]
                set -a to_delete_titles $link_titles[$idx]
                set -a to_delete_urls $link_urls[$idx]
            end
        end
    end
    rm -f $reviewfile

    set -l del_count (count $to_delete_ids)
    if test $del_count -eq 0
        echo ""
        echo "No $label articles marked for deletion."
        return 0
    end

    echo ""
    echo "$label articles to delete ($del_count):"
    for i in (seq 1 $del_count)
        echo "  - $to_delete_titles[$i]"
        echo "    $to_delete_urls[$i]"
    end
    echo ""

    read -l -P "Delete these $del_count $label articles? [y/N] " confirm
    if test "$confirm" != y -a "$confirm" != Y
        echo "Cancelled. No $label articles deleted."
        return 0
    end

    echo "Deleting..."
    set -l id_params
    for id in $to_delete_ids
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
    echo "Done. $del_count $label article(s) deleted."
end

function goodlinks_thin --description "Interactively thin out old read and unread GoodLinks articles"
    argparse 'h/help' -- $argv
    or return 1

    if set -q _flag_help
        echo "Usage: goodlinks_thin"
        echo ""
        echo "Fetches all read GoodLinks articles, picks 50 at random, and opens"
        echo "\$EDITOR with a review file listing each one's metadata and a"
        echo "commented-out \"delete <id>\" line. Uncomment the lines for articles"
        echo "you want removed, then save and close. Then does the same for"
        echo "unread articles, picking 10 at random. After each pass, marked"
        echo "articles are listed and you're asked to confirm before they're"
        echo "deleted in bulk via the GoodLinks API. Favorited and highlighted"
        echo "links are never included."
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

    __goodlinks_thin_process $token $base true 50 read
    or return 1

    echo ""
    __goodlinks_thin_process $token $base false 10 unread
    or return 1
end
