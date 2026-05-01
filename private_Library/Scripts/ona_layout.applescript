tell application "Ghostty"
	activate

	set win to new window
	set paneTopLeft to terminal 1 of selected tab of win
	set paneRight to split paneTopLeft direction right
	set paneBottomLeft to split paneTopLeft direction down

	input text "ash ona.web-dev" to paneTopLeft
	send key "enter" to paneTopLeft

	input text "ash ona.claude" to paneBottomLeft
	send key "enter" to paneBottomLeft

	input text "ash ona.editor" to paneRight
	send key "enter" to paneRight

	focus paneTopLeft
end tell
