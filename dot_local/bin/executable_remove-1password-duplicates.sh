#!/opt/homebrew/bin/bash
declare -A itemMap

# Function to extract base domain from a full domain
# e.g. secure25ea.chase.com -> chase.com
get_base_domain() {
    local domain="$1"
    # Remove any port numbers
    domain="${domain%%:*}"
    # Split by dots and get the last 2 parts (handles most cases)
    echo "$domain" | awk -F. '{if(NF>=2) print $(NF-1)"."$NF; else print $0}'
}

# Get all item IDs first to calculate total count
item_ids=($(op item list --categories Login --format=json | jq -r '.[] | select(.id != null) | .id'))
total_items=${#item_ids[@]}
current_item=0

echo "Found $total_items items to process..."

for id in "${item_ids[@]}"; do
    current_item=$((current_item + 1))
    percentage=$((current_item * 100 / total_items))
    printf "\rProcessing item %d/%d (%d%%)..." "$current_item" "$total_items" "$percentage"
    item=$(op item get $id --format=json)

    if [[ $item != null ]]; then
        fields=$(echo $item | jq -r '.fields')

        if [[ $fields != null ]]; then
            username=$(echo $fields | jq -r '.[] | select(.label=="username").value')
        fi

        urls=$(echo $item | jq -r '.urls')
        href=$(echo $urls | jq -r '.[0].href')
        website=$(echo $href | awk -F[/:] '{print $4}')

        if [[ -n $website && -n $username ]]; then
            base_domain=$(get_base_domain "$website")
            key="$base_domain-$username"

            if [[ ${itemMap[$key]} ]]; then
                echo ""
                echo "Duplicate found (base domain: $base_domain):"
                # Get the original item details
                original_item=$(op item get ${itemMap[$key]} --format=json)
                original_urls=$(echo $original_item | jq -r '.urls')
                original_href=$(echo $original_urls | jq -r '.[0].href')
                original_website=$(echo $original_href | awk -F[/:] '{print $4}')
                
                echo "Item 1: id: ${itemMap[$key]}, username: $username, website: $original_website"
                echo "Item 2: id: $id, username: $username, website: $website"
                
                # Merge URLs: combine all URLs from both items
                current_urls=$(echo $item | jq -r '.urls')
                
                # Create merged URL array - combine original URLs with current URLs, avoiding duplicates
                merged_urls=$(echo "$original_urls" "$current_urls" | jq -s '.[0] + .[1] | unique_by(.href)')
                
                # Update the original item with merged URLs
                echo "Merging URLs into item ${itemMap[$key]}..."
                temp_file=$(mktemp)
                echo $original_item | jq --argjson urls "$merged_urls" '.urls = $urls' > "$temp_file"
                
                # Update the item in 1Password
                op item edit ${itemMap[$key]} --template="$temp_file"
                rm "$temp_file"
                
                # Delete the duplicate
                op item delete $id --archive
                echo "Merged and deleted duplicate $id"
            else
                itemMap[$key]=$id
            fi
        fi
    fi
done

echo ""
echo "Processing complete!"
