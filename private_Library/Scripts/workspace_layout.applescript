tell application "Ghostty"
	activate

	set win to new window
	set paneLeft to terminal 1 of selected tab of win
	set paneTopRight to split paneLeft direction right
	set paneBottomRight to split paneTopRight direction down

	focus paneTopRight
	input text "jjui\n " to paneTopRight

	focus paneLeft
	input text "claude\n " to paneLeft
end tell
