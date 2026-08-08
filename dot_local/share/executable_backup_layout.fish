#!/usr/bin/env fish

echo (set_color blue)(date "+%H:%M:%S") "==> sync_highlights"(set_color normal)
and sync_highlights -t ~/Documents/Obsidian\ Vaults/notes/
and echo (set_color blue)(date "+%H:%M:%S") "==> sync_mochi"(set_color normal)
and sync_mochi
and echo (set_color blue)(date "+%H:%M:%S") "==> rm -rf markdown-export*"(set_color normal)
and rm -rf ~/Downloads/markdown-export*
and echo (set_color blue)(date "+%H:%M:%S") "==> sync_bookmarks import"(set_color normal)
and sync_bookmarks --links ~/.local/share/chezmoi/links.json --cache ~/cache.db import
and echo (set_color blue)(date "+%H:%M:%S") "==> sync_bookmarks raindrop"(set_color normal)
and sync_bookmarks --links ~/links.json --cache ~/cache.db raindrop
and echo (set_color blue)(date "+%H:%M:%S") "==> cd obsidian-backups"(set_color normal)
and cd ~/Developer/obsidian-backups
and echo (set_color blue)(date "+%H:%M:%S") "==> mise run copy"(set_color normal)
and mise run copy
and echo (set_color blue)(date "+%H:%M:%S") "==> backup"(set_color normal)
and backup
and echo (set_color green)(date "+%H:%M:%S") "==> done"(set_color normal)
