tell application "Ghostty"
	activate

	set paneLeft to focused terminal of selected tab of front window
	set paneTopRight to split paneLeft direction right
	set paneBottomRight to split paneTopRight direction down

	focus paneTopRight
	input text "jjui\n " to paneTopRight

	focus paneLeft
	input text "claude\n " to paneLeft
end tell
