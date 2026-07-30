tell application "Ghostty"
	activate

	set paneRight to focused terminal of selected tab of front window
	set paneTopLeft to split paneRight direction left
	set paneBottomLeft to split paneTopLeft direction down

	focus paneTopLeft
	input text "jjui\n " to paneTopLeft

	focus paneRight
	input text "claude --permission-mode auto\n " to paneRight
end tell
