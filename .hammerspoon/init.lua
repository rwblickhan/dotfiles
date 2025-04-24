hs.loadSpoon("EmmyLua")
hs.loadSpoon("LeftRightHotkey")
spoon.LeftRightHotkey:start()

local clipboardHistory = {}
local maxClipboardHistory = 10

-- Submit arrow keys when pressing ctrl + mouse buttons
local bracketTap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(event)
    local keyCode = event:getKeyCode()
    -- ctrl is coming from the keyboard, but if this event is coming from the
    -- mouse, that won't be picked up in flags
    local keyboardModifiers = hs.eventtap.checkKeyboardModifiers()
    if keyboardModifiers then
        -- ]
        if keyCode == 30 and keyboardModifiers.ctrl then
            if keyboardModifiers.alt then
                hs.eventtap.event.newKeyEvent({ 'alt' }, "up", true):post()
                hs.eventtap.event.newKeyEvent({ 'alt' }, "up", false):post()
            else
                hs.eventtap.event.newKeyEvent({}, "up", true):post()
                hs.eventtap.event.newKeyEvent({}, "up", false):post()
            end
            return true
        end
        -- [
        if keyCode == 33 and keyboardModifiers.ctrl then
            if keyboardModifiers.alt then
                hs.eventtap.event.newKeyEvent({ 'alt' }, "down", true):post()
                hs.eventtap.event.newKeyEvent({ 'alt' }, "down", false):post()
            else
                hs.eventtap.event.newKeyEvent({}, "down", true):post()
                hs.eventtap.event.newKeyEvent({}, "down", false):post()
            end
            return true
        end
    end

    return false
end)
bracketTap:start()
print("Bracket arrow keys enabled!")

-- Insert clipboard changes into local memory
local clipboardWatcher = hs.pasteboard.watcher.new(function(contents)
    if contents then
        table.insert(clipboardHistory, 1, contents)
        if #clipboardHistory > maxClipboardHistory then
            table.remove(clipboardHistory)
        end
    end
end)
if clipboardWatcher then
    clipboardWatcher:start()
end

local function isURL(text)
    if not text then return false end
    local pattern = "^https?://[%w-_%.%?%.:/%+=&%%]+$"
    return string.match(text, pattern) ~= nil
end

local function findURLAndText()
    local recentURL = nil
    local recentText = nil

    for _, item in ipairs(clipboardHistory) do
        if isURL(item) and not recentURL then
            recentURL = item
        elseif not isURL(item) and not recentText then
            recentText = item
        end

        if recentURL and recentText then
            break
        end
    end

    return recentText, recentURL
end

local function typeMarkdownLink()
    local text, url = findURLAndText()

    if not text then
        hs.alert.show("No text found in clipboard history")
        return
    end

    if not url then
        hs.alert.show("No URL found in clipboard history")
        return
    end

    local markdownLink = string.format("[%s](%s)", text, url)
    hs.eventtap.keyStrokes(markdownLink)
end

local function typeCheckbox()
    hs.eventtap.keyStrokes("- [x]")
end

local function searchHighlighted()
    hs.eventtap.keyStroke({ "cmd" }, "c")
    hs.timer.doAfter(0.1, function()
        hs.eventtap.keyStroke({ "cmd" }, "f")
        hs.timer.doAfter(0.1, function()
            hs.eventtap.keyStroke({ "cmd" }, "v")
        end)
    end)
end

spoon.LeftRightHotkey:bind({ "rOpt" }, "x", typeCheckbox)
print("Markdown checkbox config created!")

spoon.LeftRightHotkey:bind({ "rOpt" }, "l", typeMarkdownLink)
print("Markdown link config created!")

spoon.LeftRightHotkey:bind({ "rOpt" }, "f", searchHighlighted)
print("Search highlighted config created!")
