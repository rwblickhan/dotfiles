function obsidian_bookmark_to_things --description "Pick a bookmarked note from the control-plane vault via fzf and port its Markdown todos into a Things to-do"
    argparse 'h/help' -- $argv
    or return 1

    if set -q _flag_help
        echo "Usage: obsidian_bookmark_to_things"
        echo ""
        echo "Lists file bookmarks from the 'control-plane' Obsidian vault via fzf."
        echo "On selection, prompts for a Things to-do title, then creates that"
        echo "to-do in the Errands list, scheduled for today, with a subtask for"
        echo "every incomplete Markdown checkbox in the selected note."
        return 0
    end

    if not type -q obsidian
        echo "Error: obsidian CLI not found" >&2
        return 1
    end

    if not type -q fzf
        echo "Error: fzf not found" >&2
        return 1
    end

    if not type -q jq
        echo "Error: jq not found" >&2
        return 1
    end

    set -l vault control-plane

    set -l bookmarks (obsidian vault=$vault bookmarks format=tsv verbose 2>/dev/null | string match -r '^file\t.*')
    if test (count $bookmarks) -eq 0
        echo "No file bookmarks found in vault '$vault'." >&2
        return 1
    end

    set -l selection (printf '%s\n' $bookmarks | fzf --delimiter \t --with-nth 3 --prompt "Bookmark> ")
    if test -z "$selection"
        echo "No bookmark selected."
        return 1
    end

    set -l note_path (string split -f2 \t -- $selection)
    set -l note_title (string split -f3 \t -- $selection)

    read -l -P "Todo title: " todo_title
    if test -z "$todo_title"
        echo "Error: todo title cannot be empty" >&2
        return 1
    end

    set -l checklist_items (obsidian vault=$vault tasks path="$note_path" todo format=json 2>/dev/null | jq -r '.[].text | sub("^- \\[.\\]\\s*"; "")')
    if test $pipestatus[1] -ne 0
        echo "Error: failed to read tasks from '$note_path'" >&2
        return 1
    end

    # Things area id for "🏪 Errands" — more reliable than matching the emoji-prefixed name
    set -l errands_area_id 2e4RzYsukAz2prQG9ktfS3

    set -l params "title="(string escape --style=url -- $todo_title)
    set -a params "list-id=$errands_area_id"
    set -a params when=today
    if test (count $checklist_items) -gt 0
        set -l escaped_items (string escape --style=url -- $checklist_items)
        set -a params "checklist-items="(string join %0A -- $escaped_items)
    else
        echo "No incomplete Markdown todos found in '$note_path'."
    end

    open "things:///add?"(string join '&' -- $params)

    echo "Created Things to-do \"$todo_title\" in Errands (today) with "(count $checklist_items)" subtask(s) from \"$note_title\"."
end
