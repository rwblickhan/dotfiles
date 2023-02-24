function https_json_no_verify
    https -b --verify no $argv | jq
end
