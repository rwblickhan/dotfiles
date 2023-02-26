function jq_select_starred
    cat "$argv" | jq -c '.[] | select(.starred)'
end
