function new_workspace --description 'Create a new jj workspace and open it in Ghostty with claude'
    if test (count $argv) -lt 1
        echo "Usage: new_workspace <name>"
        return 1
    end

    set -l name $argv[1]
    set -l workspace_path (dirname (pwd))/$name

    jj workspace add "../$name" || return 1

    cd $workspace_path
    mise trust

    printf 'tell application "Ghostty"
    set leftPane to focused terminal of selected tab of front window

    set rightCfg to new surface configuration
    set initial working directory of rightCfg to "%s"
    set rightPane to split leftPane direction right with configuration rightCfg

    input text "claude" to leftPane
    send key "enter" to leftPane

    focus leftPane
end tell' $workspace_path | osascript
end
