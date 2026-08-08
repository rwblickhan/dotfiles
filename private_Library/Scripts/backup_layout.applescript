tell application "Ghostty"
	activate

	set win to new window
	set pane to terminal 1 of selected tab of win

	input text "~/.local/share/backup_layout.fish" & return & " " to pane
end tell
