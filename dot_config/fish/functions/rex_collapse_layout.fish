function rex_collapse_layout --description "Collapse Rex panes in this tab down to the current pane"
    set -l window (rex block inspect $REX_BLOCK --json | jq -er '.block.window_id'); or return
    set -l others (rex block ls -w $window -q --short=false | string match -v -- $REX_BLOCK)
    for block in $others
        rex block close $block &
    end
    wait
end
