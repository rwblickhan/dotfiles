function sync-terminfo --description "Sync xterm-ghostty terminfo to a remote server" --argument-names server
    if test -z "$server"
        echo "Usage: sync-terminfo YOUR-SERVER"
        return 1
    end
    infocmp -x xterm-ghostty | ssh $server -- tic -x -
end
