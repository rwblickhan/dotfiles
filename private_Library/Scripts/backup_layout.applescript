tell application "Ghostty"
	activate

	set win to new window
	set paneLeft to terminal 1 of selected tab of win
	set paneRight to split paneLeft direction right

	focus paneLeft
	input text "sync_highlights -t ~/Documents/Obsidian\\ Vaults/notes/ && sync_mochi && sync_bookmarks --links ~/.local/share/chezmoi/links.json --cache ~/cache.db import && sync_bookmarks --links ~/links.json --cache ~/cache.db raindrop && ~/Developer/obsidian-backups && mise run copy" to paneLeft
	delay 0.1
	send key "enter" to paneLeft

	focus paneRight
	input text "backup" to paneRight
	delay 0.1
	send key "enter" to paneRight
end tell
