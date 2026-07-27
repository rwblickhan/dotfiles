function notify --description "Send an OSC 9 desktop notification"
    if test (count $argv) -eq 0
        echo "Usage: notify <message>"
        echo "Triggers an OSC 9 desktop notification with the given message."
        return 1
    end

    printf '\e]9;%s\a' "$argv"
end
