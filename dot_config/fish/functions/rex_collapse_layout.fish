function rex_collapse_layout --description "Collapse Rex panes in this tab down to the current pane"
    set -l window (rex block ls -s $REX_SESSION --json | jq -er --arg b $REX_BLOCK '.blocks[] | select(.block_id == $b) | .window_id'); or return
    set -l others (rex block ls -s $REX_SESSION --json | jq -r --arg w $window --arg b $REX_BLOCK '.blocks[] | select(.window_id == $w and .block_id != $b) | .block_id')
    test (count $others) -gt 0; and rex block close -s $REX_SESSION $others
end
