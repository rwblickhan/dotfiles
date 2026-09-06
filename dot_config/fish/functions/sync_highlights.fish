# Export format:
# 
# ---
# tags: []
# source_url: {{url}}
# ---
# {{#highlights}}
# {{content_md | blockquote}}
# {{#note}}
# 
# {{note}}
# {{/note}}
# {{^is_last}}
# 
# ---
# 
# {{/is_last}}
# {{/highlights}}
# ## References
# - [{{title}}]({{url}})

function __sync_highlights_source_url --description "Extract the source_url front matter value from a markdown file, if present"
    set -l path $argv[1]
    awk '
        NR==1 && $0=="---" { infm=1; next }
        infm && $0=="---" { exit }
        infm && $0 ~ /^source_url:[ \t]*/ { sub(/^source_url:[ \t]*/, ""); print; exit }
    ' $path | string trim -c ' "\''
end

function sync_highlights --description "Sync highlighted GoodLinks articles into an Obsidian vault"
    argparse h/help 't/target=' d/dry-run v/verbose -- $argv
    or return 1

    if set -q _flag_help
        echo "Usage: sync_highlights -t TARGET [OPTIONS]"
        echo ""
        echo "Fetches highlighted GoodLinks articles, exports each one's highlights"
        echo "as markdown, and copies any not already present (matched by the"
        echo "source_url front matter field) into TARGET."
        echo ""
        echo "Options:"
        echo "  -t, --target TARGET   Target directory to copy new files into (required)"
        echo "  -d, --dry-run         Show what would be copied without copying"
        echo "  -v, --verbose         Print verbose output including import progress"
        echo "  -h, --help            Show this help"
        return 0
    end

    if not set -q _flag_target
        echo "Error: --target is required" >&2
        return 1
    end
    set -l target $_flag_target

    set -l base_url (op read "op://Private/GoodLinks/base_url" 2>/dev/null)
    set -l token (op read "op://Private/GoodLinks/token" 2>/dev/null)
    if test -z "$base_url" -o -z "$token"
        echo "Error: failed to load GoodLinks credentials from 1Password" >&2
        return 1
    end

    set -l tmp_dir (mktemp -d)

    # --- import: fetch highlighted links, export each one's highlights as markdown ---
    set -l ids
    set -l titles
    set -l limit 100
    set -l offset 0
    set -l tmpfile (mktemp)

    while true
        xh --ignore-stdin --json GET "$base_url/api/v1/lists/highlighted" \
            "Authorization:Bearer $token" \
            "limit==$limit" "offset==$offset" includeRead==true >$tmpfile 2>/dev/null
        if test $status -ne 0
            echo "Error: failed to fetch highlighted links from GoodLinks" >&2
            rm -f $tmpfile
            rm -rf $tmp_dir
            return 1
        end

        set -l page_ids (jq -r '.data[].id' $tmpfile)
        set -l page_titles (jq -r '.data[] | (.title // .id)' $tmpfile)
        set -l count (count $page_ids)
        if test $count -eq 0
            break
        end
        set -a ids $page_ids
        set -a titles $page_titles

        set -l has_more (jq -r '.hasMore // false' $tmpfile)
        if test "$has_more" != true
            break
        end
        set offset (math $offset + $count)
    end
    rm -f $tmpfile

    if set -q _flag_verbose
        echo "Found "(count $ids)" highlighted links"
    end

    for i in (seq 1 (count $ids))
        set -l id $ids[$i]
        set -l title $titles[$i]

        set -l export_file (mktemp)
        set -l err_file (mktemp)
        xh --ignore-stdin --output $export_file GET \
            "$base_url/api/v1/links/$id/highlights/export" \
            "Authorization:Bearer $token" 2>$err_file
        set -l xh_status $status

        if test $xh_status -ne 0
            if grep -q 404 $err_file
                rm -f $export_file $err_file
                continue
            else
                echo "Warning: failed to fetch highlights for '$title' ("(string trim (cat $err_file))")" >&2
                rm -f $export_file $err_file
                continue
            end
        end
        rm -f $err_file

        if set -q _flag_verbose
            if set -q _flag_dry_run
                echo "Would fetch highlights for: $title"
            else
                echo "Fetched highlights for: $title"
            end
        end

        set -l safe_title (string replace -r -a '[/\\\\:*?"<>|]' '-' -- $title | string trim)
        mv $export_file "$tmp_dir/$safe_title.md"
    end

    # --- sync: copy any new highlight files (by source_url) into target ---
    set -l existing_urls
    for f in (fd -L -t f -e md . $target 2>/dev/null)
        set -l url (__sync_highlights_source_url $f)
        if test -n "$url"
            set -a existing_urls $url
        end
    end

    for f in $tmp_dir/*.md
        test -e $f; or continue
        set -l url (__sync_highlights_source_url $f)
        test -n "$url"; or continue
        contains -- $url $existing_urls; and continue

        set -l target_path "$target/"(basename $f)
        if set -q _flag_dry_run
            if set -q _flag_verbose
                echo "Would copy $f to $target_path"
            end
        else
            mkdir -p $target
            cp $f $target_path
            echo "Copied $target_path"
        end
    end

    rm -rf $tmp_dir
end
