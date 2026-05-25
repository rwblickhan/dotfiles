function goodlinks_sync_ereader --description "Sync GoodLinks 'ereader' tagged articles to Crosspoint Reader"
    argparse 'h/help' 'host=' -- $argv
    or return 1

    if set -q _flag_help
        echo "Usage: goodlinks_sync_ereader [OPTIONS]"
        echo ""
        echo "Fetches all unread GoodLinks articles tagged 'ereader', removes stale"
        echo "files from the /GoodLinks folder on the Crosspoint Reader, and converts"
        echo "and uploads any missing articles as EPUBs."
        echo ""
        echo "Options:"
        echo "  -h, --help       Show this help"
        echo "  --host HOST      Crosspoint Reader hostname or IP (default: crosspoint.local)"
        return 0
    end

    set -l token (op read "op://Private/GoodLinks/token" 2>/dev/null)
    if test -z "$token"
        echo "Error: failed to load GoodLinks API key from 1Password"
        return 1
    end

    set -l base "http://localhost:9428/api/v1"

    set -l host crosspoint.local
    if set -q _flag_host
        set host $_flag_host
    end

    # Fetch all unread 'ereader' articles with pagination
    echo "Fetching unread 'ereader' articles..."
    set -l ids
    set -l titles
    set -l authors
    set -l limit 1000
    set -l offset 0
    set -l tmpfile (mktemp)

    while true
        xh --ignore-stdin GET "$base/links" \
            "Authorization:Bearer $token" \
            tag==ereader read==false \
            "limit==$limit" "offset==$offset" > $tmpfile 2>/dev/null
        if test $status -ne 0
            echo "Error: request failed (is GoodLinks running?)"
            rm -f $tmpfile
            return 1
        end

        set -l page_ids (jq -r '.data[] | .id' $tmpfile)
        set -l page_titles (jq -r '.data[] | (.title // "Untitled")' $tmpfile)
        set -l page_authors (jq -r '.data[] | (.author // "")' $tmpfile)

        if test (count $page_ids) -gt 0
            set -a ids $page_ids
            set -a titles $page_titles
            set -a authors $page_authors
        end

        set -l has_more (jq -r '.hasMore // false' $tmpfile)
        if test "$has_more" != true
            break
        end
        set offset (math $offset + $limit)
    end
    rm -f $tmpfile

    set -l count (count $ids)
    echo "Found $count unread 'ereader' article(s)"

    # Compute expected filenames for all articles
    set -l expected_filenames
    for title in $titles
        set -l safe_title (string replace -r -a '[^a-zA-Z0-9._-]' '_' $title)
        set -a expected_filenames "$safe_title.epub"
    end

    # Fetch device file list
    echo "Fetching file list from $host..."
    set -l device_filenames
    set -l device_json (xh --ignore-stdin GET "http://$host/api/files" path==/GoodLinks 2>/dev/null)
    if test $status -eq 0 -a -n "$device_json"
        set device_filenames (echo $device_json | jq -r '.[] | select(.isDirectory == false) | .name' 2>/dev/null)
    end
    echo "Found "(count $device_filenames)" file(s) on device"

    # Delete stale device files
    for filename in $device_filenames
        if not contains $filename $expected_filenames
            echo "Deleting stale file: $filename"
            xh --ignore-stdin --form POST "http://$host/delete" path=/GoodLinks/$filename >/dev/null
            if test $status -ne 0
                echo "Warning: failed to delete $filename"
            end
        end
    end

    # Ensure /GoodLinks directory exists
    xh --ignore-stdin --form POST "http://$host/mkdir" name=GoodLinks path=/ >/dev/null 2>&1

    # Convert and upload missing articles
    for i in (seq 1 $count)
        set -l id $ids[$i]
        set -l title $titles[$i]
        set -l author $authors[$i]
        set -l safe_title (string replace -r -a '[^a-zA-Z0-9._-]' '_' $title)
        set -l filename "$safe_title.epub"

        if contains $filename $device_filenames
            echo "Already on device: '$title'"
            continue
        end

        echo "Uploading: '$title'"

        set -l tmp_html (mktemp /tmp/goodlinks-XXXXXX.html)
        set -l tmp_dir (mktemp -d /tmp/goodlinks-XXXXXX)
        set -l tmp_epub "$tmp_dir/$filename"

        xh --ignore-stdin --output $tmp_html GET "$base/links/$id/content" \
            format==html "Authorization:Bearer $token"
        if test $status -ne 0
            echo "Error: could not fetch HTML content for '$title' — skipping"
            rm -f $tmp_html
            rm -rf $tmp_dir
            continue
        end

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
