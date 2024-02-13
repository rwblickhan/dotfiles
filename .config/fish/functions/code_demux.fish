function code_demux
    for arg in $argv
        code -g $arg
    end
end
