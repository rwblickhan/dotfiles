function jj_fork --description 'Create a new jj workspace and open it'
    if test (count $argv) -lt 1
        echo "Usage: jj_fork <name>"
        return 1
    end

    set -l name $argv[1]
    set -l workspace_path (dirname (pwd))/$name

    jj workspace add "../$name" || return 1

    cd $workspace_path
    if command -q mise
        if mise trust --show | string match -q '*untrusted*'
            mise trust
        end
    end
end
