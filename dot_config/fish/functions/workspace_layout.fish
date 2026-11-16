function workspace_layout --description "Split the current pane into the claude code workspace layout"
    switch "$TERM_PROGRAM"
        case ghostty
            ghostty_workspace_layout
        case rex
            rex_workspace_layout
        case '*'
            echo "workspace_layout: unsupported terminal '$TERM_PROGRAM'" >&2
            return 1
    end
end
