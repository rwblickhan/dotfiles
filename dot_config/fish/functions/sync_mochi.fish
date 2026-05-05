function sync_mochi --description "Sync Mochi markdown exports to an Obsidian vault"
    argparse --name sync_mochi 'h/help' 'e/edit' -- $argv
    or return 1

    if set -q _flag_help
        echo "Usage: sync_mochi [--edit]"
        echo
        echo "Syncs Mochi markdown exports to an Obsidian vault."
        echo "Config: ~/.config/sync_mochi/config"
        echo
        echo "Options:"
        echo "  -e, --edit  Refresh available decks and open config in \$EDITOR"
        echo "  -h, --help  Show this help"
        return 0
    end

    set config_file ~/.config/sync_mochi/config

    # First run: generate config and drop into editor
    if not test -f $config_file
        _sync_mochi_write_config $config_file
        echo "Created config at $config_file — edit to set vault and choose decks."
        set _flag_edit yes
    end

    if set -q _flag_edit
        if test -z "$EDITOR"
            echo "sync_mochi: \$EDITOR is not set" >&2
            return 1
        end
        # Refresh the available-decks comment from the filesystem, preserving
        # the user's vault and deck selections.
        _sync_mochi_refresh_config $config_file
        eval $EDITOR (string escape $config_file)
    end

    # Parse config -------------------------------------------------------
    set vault ""
    set decks

    while read -l line
        set line (string trim $line)
        string match -qr '^\s*#' $line; and continue
        string match -qr '^\s*$' $line; and continue

        set parts (string split -m 1 ' ' $line)
        test (count $parts) -lt 2; and continue
        set key $parts[1]
        set val (string replace -r '^~' $HOME $parts[2])

        switch $key
            case vault
                set vault $val
            case deck
                set -a decks $val
        end
    end < $config_file

    if test -z "$vault"
        echo "sync_mochi: no vault set — run: sync_mochi --edit" >&2
        return 1
    end

    if test (count $decks) -eq 0
        echo "sync_mochi: no decks selected — run: sync_mochi --edit" >&2
        return 1
    end

    if not test -d $vault
        echo "sync_mochi: vault does not exist: $vault" >&2
        return 1
    end

    # Sync ---------------------------------------------------------------
    set known_ids (rg --no-filename -o '^mochi-id: (.+)$' -r '$1' --glob '*.md' $vault 2>/dev/null)
    set copied 0
    set skipped 0

    for deck in $decks
        if not test -d $deck
            echo "sync_mochi: deck not found: $deck" >&2
            continue
        end

        for src_file in (find $deck -name "*.md" -type f | sort)
            set fname (basename $src_file)
            set id (string match --regex '^([A-Za-z0-9]+) - ' $fname)[2]
            test -z "$id"; and continue

            if contains -- $id $known_ids
                set skipped (math $skipped + 1)
                continue
            end

            set dest_fname (string replace -r '^[A-Za-z0-9]+ - ' '' $fname)
            echo "Copying: $dest_fname"
            set dest "$vault/$dest_fname"
            echo '---' > $dest
            echo "mochi-id: $id" >> $dest
            echo '---' >> $dest
            perl -0777 -pe 's/([^\n])\n---/$1\n\n---/g; s/---\n([^\n])/---\n\n$1/g' $src_file >> $dest

            set -a known_ids $id
            set copied (math $copied + 1)
        end
    end

    echo
    echo "Done: $copied copied, $skipped already synced"
end

# Scan ~/Downloads/markdown-export for Mochi deck directories
function _sync_mochi_detect_decks
    set export_root ~/Downloads/markdown-export
    test -d $export_root; or return
    find $export_root -maxdepth 1 -mindepth 1 -type d | sort | while read -l d
        string match -qr '^[A-Za-z0-9]{8} - ' (basename $d); and echo $d
    end
end

# Create the config file from scratch (all decks commented out)
function _sync_mochi_write_config
    set config_file $argv[1]
    mkdir -p (dirname $config_file)

    set available (_sync_mochi_detect_decks)

    echo '# sync_mochi config' > $config_file
    echo '# Run "sync_mochi --edit" to refresh deck list and edit.' >> $config_file
    echo >> $config_file

    if test (count $available) -gt 0
        # Article pattern: one comment line listing all available options
        echo -n '# Available decks:' >> $config_file
        for d in $available
            echo -n " $(basename $d)" >> $config_file
        end
        echo >> $config_file
        echo >> $config_file
    end

    echo 'vault ~/Documents/Obsidian Vaults/mochi' >> $config_file
    echo >> $config_file
    echo '# Decks to sync — uncomment or add lines below:' >> $config_file

    if test (count $available) -gt 0
        for d in $available
            echo "# deck $d" >> $config_file
        end
    else
        echo '# deck ~/Downloads/markdown-export/<ID> - <Name>' >> $config_file
    end
end

# Rewrite the config, refreshing the available-decks comment while
# preserving the user's vault and active deck selections.
function _sync_mochi_refresh_config
    set config_file $argv[1]

    # Read existing settings
    set old_vault ""
    set old_decks

    while read -l line
        set line (string trim $line)
        string match -qr '^\s*#' $line; and continue
        string match -qr '^\s*$' $line; and continue

        set parts (string split -m 1 ' ' $line)
        test (count $parts) -lt 2; and continue
        switch $parts[1]
            case vault
                set old_vault $parts[2]
            case deck
                set -a old_decks $parts[2]
        end
    end < $config_file

    set available (_sync_mochi_detect_decks)

    # Rewrite with fresh header
    echo '# sync_mochi config' > $config_file
    echo '# Run "sync_mochi --edit" to refresh deck list and edit.' >> $config_file
    echo >> $config_file

    if test (count $available) -gt 0
        echo -n '# Available decks:' >> $config_file
        for d in $available
            echo -n " $(basename $d)" >> $config_file
        end
        echo >> $config_file
        echo >> $config_file
    end

    if test -n "$old_vault"
        echo "vault $old_vault" >> $config_file
    else
        echo 'vault ~/Documents/Obsidian Vaults/mochi' >> $config_file
    end

    echo >> $config_file
    echo '# Decks to sync:' >> $config_file

    for d in $available
        if contains -- $d $old_decks
            echo "deck $d" >> $config_file
        else
            echo "# deck $d" >> $config_file
        end
    end

    # Preserve any deck entries that aren't in the detected list
    # (e.g. decks from a non-standard location)
    for d in $old_decks
        if not contains -- $d $available
            echo "deck $d" >> $config_file
        end
    end
end
