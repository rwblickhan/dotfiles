function jj_join --description "Remove this jj workspace and cd back to the default workspace"
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

    if not jj workspace root --name $name >/dev/null 2>&1
        echo "No such workspace: $name" >&2
        return 1
    end

    cd $default_root
    jj workspace remove $name; or return 1

    echo "Joined workspace '$name'; back in $default_root"
end
