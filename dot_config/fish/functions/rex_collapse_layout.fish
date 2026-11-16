function rex_collapse_layout --description "Collapse Rex panes in this tab down to the current pane"
    set -l others (rex block ls -s $REX_SESSION --json | jq -er --arg b $REX_BLOCK '(.blocks[] | select(.block_id == $b) | .window_id) as $w | .blocks[] | select(.window_id == $w and .block_id != $b) | .block_id'); or return 0
    for block in $others
        rex block close -s $REX_SESSION $block &
    end
    wait
end
