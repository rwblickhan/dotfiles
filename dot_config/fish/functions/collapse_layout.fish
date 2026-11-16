function collapse_layout --description "Collapse panes in this tab down to the current pane"
    switch "$TERM_PROGRAM"
        case ghostty
            ghostty_collapse_layout
        case rex
            rex_collapse_layout
        case '*'
            echo "collapse_layout: unsupported terminal '$TERM_PROGRAM'" >&2
            return 1
    end
end
