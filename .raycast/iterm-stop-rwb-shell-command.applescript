#!/usr/bin/osascript

# Dependency: requires iTerm (https://iterm2.com)
# Install via Homebrew: `brew install --cask iterm2`

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Stop rwb
# @raycast.mode silent
# @raycast.packageName iTerm

# Optional parameters:
# @raycast.icon images/iterm.png

# Documentation
# @raycast.author Andrei Borisov
# @raycast.authorURL https://github.com/andreiborisov

-- Set this property to true to open in a new window instead of a new tab
property open_in_new_window : false

-- Handlers
on new_window()
	tell application "iTerm" to create window with default profile
end new_window

on new_tab()
	tell application "iTerm" to tell the first window to create tab with default profile
end new_tab

on call_forward()
	tell application "iTerm" to activate
end call_forward

on is_running()
	application "iTerm" is running
end is_running

on is_processing()
	tell application "iTerm" to tell the first window to tell current session to get is processing
end is_processing

on has_windows()
	if not is_running() then return false
	if windows of application "iTerm" is {} then return false
	true
end has_windows

on send_text()
	tell application "iTerm" to tell the first window to tell current session to write text "tmuxinator stop rwb"
end send_text

on quit_iterm()
	tell application "iTerm" to quit
end quit_iterm

on quit_vscode()
	tell application "Visual Studio Code" to quit
end quit_vscode

-- Main
on run
	if has_windows() then
		-- Open the command in the current session unless it has a running command, e.g., ssh or top
		if is_processing() then
			if open_in_new_window then
				new_window()
			else
				new_tab()
			end if
		end if
	else
		-- If iTerm is not running and we tell it to create a new window, we get two
		-- One from opening the application, and the other from the command
		if is_running() then
			new_window()
		else
			call_forward()
		end if
	end if

	-- Make sure a window exists before we continue, or the write may fail
	repeat until has_windows()
		delay 0.01
	end repeat

	call_forward()
	send_text()
	delay 0.1
	repeat while is_processing()
		delay 0.01
	end repeat
	quit_iterm()
	quit_vscode()
end run