tell application "Ghostty"
	activate

	set theTab to selected tab of front window
	set activeID to id of (focused terminal of theTab)

	repeat while (count of terminals of theTab) > 1
		set didClose to false
		repeat with t in terminals of theTab
			if id of t is not activeID then
				close t
				set didClose to true
				exit repeat
			end if
		end repeat
		if not didClose then exit repeat
	end repeat

	focus (terminal 1 of theTab)
end tell
