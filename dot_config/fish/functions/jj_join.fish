function jj_join --description "Rebase this jj workspace onto trunk, forget and delete it, and cd back to the default workspace"
    set -l name $argv[1]

    set -l current_root (jj workspace root)
    set -l default_root (jj workspace root --name default)

    if test -z "$name"
        for ws in (jj workspace list -T 'name ++ "\n"')
            if test (jj workspace root --name $ws) = "$current_root"
                set name $ws
                break
            end
        end
        if test -z "$name"
            echo "Could not determine the current workspace; pass a name explicitly." >&2
            return 1
        end
    end

    if test "$name" = default
        echo "Refusing to join the default workspace." >&2
        return 1
    end

    set -l path (jj workspace root --name $name 2>/dev/null)
    if test -z "$path"
        echo "No such workspace: $name" >&2
        return 1
    end

    cd $path
    jj rebase -b "$name@" -o 'trunk()' --skip-emptied; or return 1

    cd $default_root
    jj workspace forget $name; or return 1
    rm -rf -- $path

    echo "Joined workspace '$name'; back in $default_root"
end
