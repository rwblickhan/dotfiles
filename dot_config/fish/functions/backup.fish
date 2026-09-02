function backup
    set -gx AWS_ACCESS_KEY_ID (op read "op://Private/Cloudflare Backups/access_key_id")
    set -gx AWS_SECRET_ACCESS_KEY (op read "op://Private/Cloudflare Backups/secret_access_key")

    echo (set_color blue)(date "+%H:%M:%S") "==> sync_highlights"(set_color normal)
    sync_highlights -t ~/Documents/Obsidian\ Vaults/notes/

    echo (set_color blue)(date "+%H:%M:%S") "==> sync_mochi"(set_color normal)
    sync_mochi

    echo (set_color blue)(date "+%H:%M:%S") "==> rm -rf markdown-export*"(set_color normal)
    rm -rf ~/Downloads/markdown-export*

    echo (set_color blue)(date "+%H:%M:%S") "==> sync_bookmarks import"(set_color normal)
    sync_bookmarks --links ~/links.json --cache ~/cache.db import

    echo (set_color blue)(date "+%H:%M:%S") "==> sync_bookmarks raindrop"(set_color normal)
    sync_bookmarks --links ~/links.json --cache ~/cache.db raindrop

    echo (set_color blue)(date "+%H:%M:%S") "==> backup"(set_color normal)
    restic -r s3:(r2b_endpoint) backup --verbose ~/Calibre\ Library/ ~/Desktop/ ~/Developer/ ~/Documents/ ~/Downloads/ ~/Movies/Personal/ ~/Music/Personal/ ~/Pictures/Personal/ ~/Documents/Obsidian\ Vaults

    echo (set_color green)(date "+%H:%M:%S") "==> done"(set_color normal)

end
