function __complete_gs
    set -lx COMP_LINE (commandline -cp)
    test -z (commandline -ct)
    and set COMP_LINE "$COMP_LINE "
    /opt/homebrew/bin/gs
end
complete -f -c gs -a "(__complete_gs)"
