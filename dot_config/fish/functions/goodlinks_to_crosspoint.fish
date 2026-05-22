function goodlinks_to_crosspoint --description "Fetch a GoodLinks article, convert to EPUB, and upload to Crosspoint Reader"
    argparse 'h/help' 'host=' -- $argv
    or return 1

    if set -q _flag_help
        echo "Usage: goodlinks_to_crosspoint [OPTIONS] <search-query>"
        echo ""
        echo "Searches GoodLinks by title, converts the article to EPUB via pandoc,"
        echo "and uploads it to the /GoodLinks directory on a Crosspoint Reader."
        echo "If multiple articles match, an interactive picker is shown (Tab to multiselect)."
        echo ""
        echo "Options:"
        echo "  -h, --help       Show this help"
        echo "  --host HOST      Crosspoint Reader hostname or IP (default: crosspoint.local)"
        return 0
    end

    if test (count $argv) -ne 1
        echo "Usage: goodlinks_to_crosspoint [OPTIONS] <search-query>"
        return 1
    end

    set -l token (op read "op://Private/GoodLinks/token" 2>/dev/null)
    if test -z "$token"
        echo "Error: failed to load GoodLinks API key from 1Password"
        return 1
    end

    set -l query $argv[1]
    set -l base "http://localhost:9428/api/v1"

    set -l host crosspoint.local
    if set -q _flag_host
        set host $_flag_host
    end

    # Search for matching unread articles
    echo "Searching for '$query'..."
    set -l results (xh --ignore-stdin GET "$base/links" \
        "Authorization:Bearer $token" search==$query read==false limit==50)
    if test $status -ne 0
        echo "Error: search request failed (is GoodLinks running?)"
        return 1
    end
    if test -z "$results"
        echo "Error: empty response from GoodLinks API"
        return 1
    end

    set -l count (echo $results | jq '.data | length')
    if test $count -eq 0
        echo "No unread articles found matching '$query'"
        return 1
    end
    echo "Found $count match(es)"

    # Resolve IDs — declare outside the if/else so the variable survives the block
    set -l ids
    if test $count -eq 1
        set ids (echo $results | jq -r '.data[0].id')
    else
        set ids (echo $results | \
            jq -r '.data[] | "\(.id)\t\(.title)\t\(.url)"' | \
            fzf --prompt "Select articles: " \
                --delimiter \t \
                --with-nth 2.. \
                --multi | \
            cut -f1)
        if test -z "$ids"
            echo "No articles selected"
            return 1
        end
    end
    echo "Selected "(count $ids)" article(s)"

    # Ensure /GoodLinks directory exists (ignore error if it already does)
    xh --ignore-stdin --form POST "http://$host/mkdir" name=GoodLinks path=/ >/dev/null 2>&1

    for id in $ids
        echo "Fetching metadata for $id..."
        set -l meta (xh --ignore-stdin GET "$base/links/$id" "Authorization:Bearer $token")
        if test $status -ne 0 -o -z "$meta"
            echo "Error: could not fetch metadata for article '$id' — skipping"
            continue
        end

        set -l title (echo $meta | jq -r '.title // "Untitled"')
        set -l author (echo $meta | jq -r '.author // ""')
        echo "Processing '$title'..."

        set -l tmp_html (mktemp /tmp/goodlinks-XXXXXX.html)
        set -l tmp_dir (mktemp -d /tmp/goodlinks-XXXXXX)

        echo "  Downloading HTML content..."
        xh --ignore-stdin --output $tmp_html GET "$base/links/$id/content" \
            format==html "Authorization:Bearer $token"
        if test $status -ne 0
            echo "Error: could not fetch HTML content for '$title' — skipping"
            rm -f $tmp_html
            rm -rf $tmp_dir
            continue
        end

        set -l safe_title (string replace -r -a '[^a-zA-Z0-9._-]' '_' $title)
        set -l filename "$safe_title.epub"
        set -l tmp_epub "$tmp_dir/$filename"

        echo "  Converting to EPUB..."
        set -l pandoc_args -f html -t epub -o $tmp_epub --metadata "title=$title"
        if test -n "$author"
            set -a pandoc_args --metadata "author=$author"
        end

        pandoc $pandoc_args $tmp_html
        if test $status -ne 0
            echo "Error: pandoc conversion failed for '$title' — skipping"
            rm -f $tmp_html
            rm -rf $tmp_dir
            continue
        end
        rm -f $tmp_html

        echo "  Uploading to Crosspoint at $host..."
        xh --ignore-stdin --multipart POST "http://$host/upload" \
            path==/GoodLinks "file@$tmp_epub"
        set -l upload_status $status
        rm -rf $tmp_dir

        if test $upload_status -ne 0
            echo "Error: upload failed for '$title'"
        else
            echo "  Done: '$title' → /GoodLinks/$filename"
        end
    end
end
