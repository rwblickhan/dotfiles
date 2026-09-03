#!/usr/bin/env fish

if test (uname) != Darwin
    exit 0
end

# Quit CleanShot X to avoid overwriting the defaults we're about to write
set cleanshotWasRunning 0
if pgrep -q -f "CleanShot X"
    set cleanshotWasRunning 1
    killall "CleanShot X"
    while pgrep -q -f "CleanShot X"
        sleep 0.1
    end
end

# CleanShot X (pl.maketheweb.cleanshotx)
defaults write pl.maketheweb.cleanshotx exportPath "$HOME/Pictures/Screenshots"
defaults write pl.maketheweb.cleanshotx captureWithoutDesktopIcons -bool true
defaults write pl.maketheweb.cleanshotx highlightClicks -bool true
defaults write pl.maketheweb.cleanshotx autoClosePopup -bool true
defaults write pl.maketheweb.cleanshotx deletePopupAfterDragging -bool true
defaults write pl.maketheweb.cleanshotx displayRecordingTime -bool false
defaults write pl.maketheweb.cleanshotx LAVAqaoRestore -data 7b22636172626f6e4b6579223a31392c22636172626f6e4d6f64696669657273223a3736387d # cmd+shift+2
defaults write pl.maketheweb.cleanshotx LAVAtakeFullscreen -data 7b22636172626f6e4b6579223a32302c22636172626f6e4d6f64696669657273223a3736387d # cmd+shift+3
defaults write pl.maketheweb.cleanshotx LAVAtakeArea -data 7b22636172626f6e4b6579223a32312c22636172626f6e4d6f64696669657273223a3736387d # cmd+shift+4
defaults write pl.maketheweb.cleanshotx LAVAtakeAllInOne -data 7b22636172626f6e4b6579223a32332c22636172626f6e4d6f64696669657273223a3736387d # cmd+shift+5
defaults write pl.maketheweb.cleanshotx LAVArecordVideo -data 7b22636172626f6e4b6579223a32322c22636172626f6e4d6f64696669657273223a3736387d # cmd+shift+6

if test $cleanshotWasRunning -eq 1
    open -a "CleanShot X"
end

# Soulver (app.soulver.appstore.mac)
defaults write app.soulver.appstore.mac SV_QUICKSOULVER_SHOWS_IN_MENU_BAR -bool true
defaults write app.soulver.appstore.mac SV_AFTER_LAUNCH_ACTION newSheetInDefaultSheetbook

# QuickSoulver hotkey (Hyper+=): carbonKeyCode 24 is "=", carbonModifiers 6912 is hyper (cmd+opt+ctrl+shift)
defaults write app.soulver.appstore.mac KeyboardShortcuts_toggleQuickSoulver -string '{"carbonKeyCode":24,"carbonModifiers":6912}'

# Bloom (com.asiafu.Bloom)
defaults write com.asiafu.Bloom BloomDefaultTerminal "file:///Applications/Ghostty.app/"
defaults write com.asiafu.Bloom BloomDefaultTextEditor "file:///Applications/iA%20Writer.app/"

# Global search hotkey (Hyper+f): carbonKeyCode 3 is "f", carbonModifiers 6912 is hyper (cmd+opt+ctrl+shift)
defaults write com.asiafu.Bloom KeyboardShortcuts_com.asiafu.Bloom.openGlobalFinder -string '{"carbonModifiers":6912,"carbonKeyCode":3}'

# Pastebot (com.tapbots.Pastebot3Mac)
defaults write com.tapbots.Pastebot3Mac MaxNumberClipboardEntries -int 1000
defaults write com.tapbots.Pastebot3Mac QuickPasteShowsSmartPastebins -bool true

set pastebotPlist "$HOME/Library/Containers/com.tapbots.Pastebot3Mac/Data/Library/Preferences/com.tapbots.Pastebot3Mac.plist"
if test -e $pastebotPlist
    # Paste-with-last-filter hotkey (cmd+option+v)
    /usr/libexec/PlistBuddy \
        -c "Delete :GlobalPasteCurrentClipboardItemWithLastUsedFilterHotKey" \
        $pastebotPlist 2>/dev/null
    /usr/libexec/PlistBuddy \
        -c "Add :GlobalPasteCurrentClipboardItemWithLastUsedFilterHotKey dict" \
        -c "Add :GlobalPasteCurrentClipboardItemWithLastUsedFilterHotKey:chars string v" \
        -c "Add :GlobalPasteCurrentClipboardItemWithLastUsedFilterHotKey:keyCode integer 9" \
        -c "Add :GlobalPasteCurrentClipboardItemWithLastUsedFilterHotKey:modifierFlags integer 1573160" \
        $pastebotPlist
end
