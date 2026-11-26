function rex_workspace_layout --description "Split the current Rex pane into the claude code workspace layout"
    set -l top_left (rex split -b $REX_BLOCK --split=left --focus=false -c $PWD --json -- fish -C jjui | jq -er '.block_ids[0]'); or return
    rex split -b $top_left --split=below --focus=false -c $PWD --json >/dev/null; or return

    claude --permission-mode auto
end
