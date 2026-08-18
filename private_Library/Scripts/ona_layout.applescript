tell application "Ghostty"
	activate

	set paneTopLeft to focused terminal of selected tab of front window
	set paneBottomLeft to split paneTopLeft direction down
	set paneTopRight to split paneTopLeft direction right
	set paneBottomRight to split paneBottomLeft direction right

	focus paneTopLeft
	input text "autossh -M 0 -q ona.jjui\n " to paneTopLeft

	focus paneBottomLeft
	input text "autossh -M 0 -q ona.editor\n " to paneBottomLeft

	focus paneTopRight
	input text "autossh -M 0 -q ona.web-dev\n " to paneTopRight

	focus paneBottomRight
	input text "autossh -M 0 -q ona.claude\n " to paneBottomRight
end tell
