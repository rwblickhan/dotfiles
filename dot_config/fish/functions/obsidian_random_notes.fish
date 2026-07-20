function obsidian_random_notes --description 'Open 10 random notes from the notes vault in new tabs'
    for i in (seq 10)
        echo "Opening random note..."
        obsidian vault=notes random newtab
    end
end
