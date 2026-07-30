function jj_workspace_layout --description 'Create a new jj workspace and open it in Ghostty with claude'
    if test (count $argv) -lt 1
        echo "Usage: new_workspace <name>"
        return 1
    end

    set -l name $argv[1]
    set -l workspace_path (dirname (pwd))/$name

    jj workspace add "../$name" || return 1

    cd $workspace_path
    mise trust
    workspace_layout
end
