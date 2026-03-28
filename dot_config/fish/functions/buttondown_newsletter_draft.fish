function buttondown_newsletter_draft --description "Create a Buttondown draft from a newsletter markdown file"
    if test (count $argv) -ne 1
        echo "Usage: buttondown_newsletter_draft <path-to-newsletter.md>"
        return 1
    end

    set -l filepath $argv[1]

    if not test -f $filepath
        echo "File not found: $filepath"
        return 1
    end

    set -l BUTTONDOWN_API_KEY (op read "op://Private/Buttondown Sync/api_key" 2>/dev/null)
    if test -z "$BUTTONDOWN_API_KEY"
        echo "Failed to load Buttondown API key from 1Password"
        return 1
    end

    # Extract title from frontmatter
    set -l title (rg '^title:' $filepath | sd '^title:\s*' '')

    if test -z "$title"
        echo "Could not find title in frontmatter"
        return 1
    end

    # Extract body: everything after the closing --- of frontmatter
    set -l body (awk '/^---$/{n++; if(n==2){found=1; next}} found{print}' $filepath | string collect)

    # Convert :::aside{...} ... ::: blocks to blockquotes
    set -l body (printf '%s' "$body" | awk '/^:::aside/{in_aside=1; next} /^:::$/ && in_aside{in_aside=0; next} in_aside{print "> " $0; next} {print}' | string collect)

    set -l base_name (basename $filepath .md)

    # Resolve relative image URLs to absolute using the published website
    set -l page_html (curl -sL "https://rwblickhan.org/newsletters/$base_name" | string collect)
    if test -n "$page_html"
        set -l img_paths (printf '%s' "$body" | rg -o '!\[[^\]]*\]\(([^)]+\.(jpe?g|png|gif|webp|avif|svg))\)' -r '$1')
        for img_path in $img_paths
            set -l img_stem (string replace -r '\.[^.]+$' '' (basename "$img_path"))
            set -l src_pattern (string join '' 'src="([^"]*' $img_stem '[^"]*)"')
            set -l matches (printf '%s' "$page_html" | rg -o $src_pattern -r '$1')
            if test (count $matches) -gt 0
                set body (string replace "$img_path" "https://rwblickhan.org$matches[1]" "$body" | string collect)
            end
        end
    end

    # Prepend website notice
    set -l notice "> Just a heads up! This will look better on [my website](https://rwblickhan.org/newsletters/$base_name)."
    set -l body (printf '<!-- buttondown-editor-mode: plaintext -->\n%s\n\n%s' "$notice" "$body" | string collect)

    # Create draft via Buttondown API
    echo "Creating draft: $title"
    jq -n \
        --arg subject "$title" \
        --arg body "$body" \
        '{subject: $subject, body: $body, status: "draft"}' \
    | xh POST https://api.buttondown.email/v1/emails \
        Authorization:"Token $BUTTONDOWN_API_KEY"
end
