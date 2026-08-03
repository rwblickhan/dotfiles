function obsidian_base_to_things --description "Pick a base and view from the control-plane vault via fzf and port its items into a Things to-do"
    argparse 'h/help' -- $argv
    or return 1

    if set -q _flag_help
        echo "Usage: obsidian_base_to_things"
        echo ""
        echo "Lists base files from the 'control-plane' Obsidian vault via fzf,"
        echo "then lists that base's views via fzf. On selection, prompts (via"
        echo "fzf) for which Things list to use, then for a to-do title, then"
        echo "creates that to-do in the chosen list, scheduled for today, with"
        echo "a subtask for every item in the selected base view."
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

    set -l bases (obsidian vault=$vault bases 2>/dev/null)
    if test (count $bases) -eq 0
        echo "No bases found in vault '$vault'." >&2
        return 1
    end

    set -l base_path (printf '%s\n' $bases | fzf --prompt "Base> ")
    if test -z "$base_path"
        echo "No base selected."
        return 1
    end

    set -l views (obsidian vault=$vault base:views path="$base_path" 2>/dev/null)
    if test (count $views) -eq 0
        echo "No views found in base '$base_path'." >&2
        return 1
    end

    set -l view_selection (printf '%s\n' $views | fzf --delimiter \t --with-nth 1 --prompt "View> ")
    if test -z "$view_selection"
        echo "No view selected."
        return 1
    end
    set -l view_name (string split -f1 \t -- $view_selection)

    # Things area names/ids, in fzf display order
    set -l list_names "🏪 Errands" "💵 Finance" "👟Health & Athletics" "✒️ Hobbies" "🦭 Relationships, Events, & Travel" "🖥️ Work"
    set -l list_ids 2e4RzYsukAz2prQG9ktfS3 TA3j5otm3UBKzBRS1x7zEz MjsDscyxCe17qMBaS871uA GhbTFDzk2VBdg3uVsnSD2Q MrpX2ED1oMuJ4MygFiTBgG 5JRNivfSJHMTNfThmN4mWp

    set -l list_selection (printf '%s\n' $list_names | fzf --prompt "List> ")
    if test -z "$list_selection"
        echo "No list selected."
        return 1
    end
    set -l list_index (contains -i -- $list_selection $list_names)
    set -l list_id $list_ids[$list_index]

    read -l -P "Todo title: " todo_title
    if test -z "$todo_title"
        echo "Error: todo title cannot be empty" >&2
        return 1
    end

    set -l checklist_items (obsidian vault=$vault base:query path="$base_path" view="$view_name" format=json 2>/dev/null | jq -r '.[]."file name"')
    if test $pipestatus[1] -ne 0
        echo "Error: failed to query base '$base_path' view '$view_name'" >&2
        return 1
    end

    set -l params "title="(string escape --style=url -- $todo_title)
    set -a params "list-id=$list_id"
    set -a params when=today
    if test (count $checklist_items) -gt 0
        set -l escaped_items (string escape --style=url -- $checklist_items)
        set -a params "checklist-items="(string join %0A -- $escaped_items)
    else
        echo "No items found in base '$base_path' view '$view_name'."
    end

    open "things:///add?"(string join '&' -- $params)

    echo "Created Things to-do \"$todo_title\" in $list_selection (today) with "(count $checklist_items)" subtask(s) from \"$base_path\" ($view_name)."
end
