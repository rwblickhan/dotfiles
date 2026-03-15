function https_json_no_verify
    xh --https -b --no-verify $argv | jq
end
