tell application "Ghostty"
	activate

	set win to new window
    set paneTopLeft to terminal 1 of selected tab of win
	set paneRight to split paneTopLeft direction right
	set paneBottomLeft to split paneTopLeft direction down

	focus paneTopLeft
	input text "autossh -M 0 -q ona.web-dev" to paneTopLeft
	delay 0.1
	send key "enter" to paneTopLeft

	focus paneBottomLeft
	input text "autossh -M 0 -q ona.claude" to paneBottomLeft
	delay 0.1
	send key "enter" to paneBottomLeft

	focus paneRight
	input text "autossh -M 0 -q ona.editor" to paneRight
	delay 0.1
	send key "enter" to paneRight
end tell
