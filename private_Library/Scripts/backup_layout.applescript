tell application "Ghostty"
	activate

	set win to new window
	set paneTopLeft to terminal 1 of selected tab of win
	set paneTopRight to split paneTopLeft direction right
	set paneBottomLeft to split paneTopLeft direction down
	set paneBottomRight to split paneTopRight direction down

	focus paneTopLeft
	input text "sync_highlights -t ~/Documents/Obsidian\\ Vaults/notes/" to paneTopLeft
	delay 0.1
	send key "enter" to paneTopLeft

	focus paneTopRight
	input text "cd sync_bookmarks && sync_bookmarks import && sync_bookmarks raindrop" to paneTopRight
	delay 0.1
	send key "enter" to paneTopRight

	focus paneBottomLeft
	input text "backup" to paneBottomLeft
	delay 0.1
	send key "enter" to paneBottomLeft

	focus paneBottomRight
	input text "sync_mochi" to paneBottomRight
	delay 0.1
	send key "enter" to paneBottomRight
end tell
