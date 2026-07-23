tell application "Ghostty"
	activate

	set win to new window
    set paneTopLeft to terminal 1 of selected tab of win
	set paneTopRight to split paneTopLeft direction right
	set paneBottomLeft to split paneTopLeft direction down
	set paneBottomRight to split paneTopRight direction down

	focus paneTopLeft
	input text "autossh -M 0 -q ona.web-dev\n " to paneTopLeft

	focus paneBottomLeft
	input text "autossh -M 0 -q ona.claude\n " to paneBottomLeft

	focus paneTopRight
	input text "autossh -M 0 -q ona.jjui\n " to paneTopRight

	focus paneBottomRight
	input text "autossh -M 0 -q ona.editor\n " to paneBottomRight
end tell
