function fix_markdown
    set -l tmpfile (mktemp /tmp/fix_markdown_XXXXXX.md)
    cat > $tmpfile
    markdownlint $tmpfile --fix 2>/dev/null; or true
    sd 'lastUpdatedDate: \d\d\d\d-\d\d-\d\d' "lastUpdatedDate: "(date +%Y-%m-%d) $tmpfile
    cat $tmpfile
    rm $tmpfile
end
