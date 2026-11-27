function open --wraps open --description 'open, but send directories to Bloom'
    if test (count $argv) -eq 0
        command open
        return
    end

    for arg in $argv
        if not test -d "$arg"; or string match -q -- '-*' $arg
            command open $argv
            return
        end
    end

    command open -a Bloom $argv
end
