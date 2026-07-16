tell application "Ghostty"
	activate

	set win to new window
    set paneTopLeft to terminal 1 of selected tab of win
	set paneRight to split paneTopLeft direction right
	set paneBottomLeft to split paneTopLeft direction down

	focus paneTopLeft
	input text "autossh -M 0 -q ona.web-dev\n " to paneTopLeft

	focus paneBottomLeft
	input text "autossh -M 0 -q ona.claude\n " to paneBottomLeft

	focus paneRight
	input text "autossh -M 0 -q ona.editor\n " to paneRight
end tell
