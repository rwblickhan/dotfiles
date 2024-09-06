function jsonpp
    if test (count $argv) -eq 0
        echo "Error: No JSON string provided."
        return 1
    end

    echo $argv[1] | jq '.'
end
