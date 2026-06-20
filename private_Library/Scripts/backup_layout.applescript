tell application "Ghostty"
	activate

	set win to new window
	set paneLeft to terminal 1 of selected tab of win
	set paneRight to split paneLeft direction right

	focus paneLeft
	input text "sync_highlights -t ~/Documents/Obsidian\\ Vaults/notes/ && sync_mochi && cd sync_bookmarks && sync_bookmarks import && sync_bookmarks raindrop" to paneLeft
	delay 0.1
	send key "enter" to paneLeft

	focus paneRight
	input text "backup" to paneRight
	delay 0.1
	send key "enter" to paneRight
end tell
