tell application "Ghostty"
	activate

	set win to new window
	set paneTopLeft to terminal 1 of selected tab of win
	set paneRight to split paneTopLeft direction right
	set paneBottomLeft to split paneTopLeft direction down

	input text "ssh ona.web-dev" to paneTopLeft
	send key "enter" to paneTopLeft

	input text "ssh ona.claude" to paneBottomLeft
	send key "enter" to paneBottomLeft

	input text "ssh ona.editor" to paneRight
	send key "enter" to paneRight

	focus paneTopLeft
end tell
