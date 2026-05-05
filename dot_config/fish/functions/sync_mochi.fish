function sync_mochi --description "Sync Mochi markdown exports to an Obsidian vault"
    argparse --name sync_mochi 'h/help' -- $argv
    or return 1

    if set -q _flag_help
        echo "Usage: sync_mochi"
        echo
        echo "Syncs Mochi markdown exports to an Obsidian vault."
        echo "Opens \$EDITOR each run to choose decks and vault path."
        echo
        echo "Options:"
        echo "  -h, --help  Show this help"
        return 0
    end

    if test -z "$EDITOR"
        echo "sync_mochi: \$EDITOR is not set" >&2
        return 1
    end

    set tmpfile (mktemp /tmp/sync_mochi.XXXXXX)
    _sync_mochi_write_config $tmpfile
    eval $EDITOR (string escape $tmpfile)

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
    end < $tmpfile

    rm -f $tmpfile

    if test -z "$vault"
        echo "sync_mochi: no vault set in config" >&2
        return 1
    end

    if test (count $decks) -eq 0
        echo "sync_mochi: no decks selected" >&2
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

# Write a fresh config to the given file path
function _sync_mochi_write_config
    set config_file $argv[1]
    set available (_sync_mochi_detect_decks)

    echo '# sync_mochi — save and close to run' > $config_file
    echo >> $config_file

    if test (count $available) -gt 0
        echo -n '# Available decks:' >> $config_file
        for d in $available
            echo -n " $(basename $d)" >> $config_file
        end
        echo >> $config_file
        echo >> $config_file
    end

    echo 'vault ~/Documents/Obsidian Vaults/mochi' >> $config_file
    echo >> $config_file
    echo '# Decks to sync — uncomment to enable:' >> $config_file

    if test (count $available) -gt 0
        for d in $available
            echo "# deck $d" >> $config_file
        end
    else
        echo '# deck ~/Downloads/markdown-export/<ID> - <Name>' >> $config_file
    end
end
