function jq_select_starred
    cat "$argv" | jq '.[] | select(.starred)'
end
