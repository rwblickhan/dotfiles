hs.loadSpoon("EmmyLua")
hs.loadSpoon("LeftRightHotkey")
spoon.LeftRightHotkey:start()

local function typeCheckbox()
    hs.eventtap.keyStrokes("- [x]")
end

spoon.LeftRightHotkey:bind({ "rOpt" }, "x", typeCheckbox)
print("Markdown checkbox config created!")

local function sendDownArrow()
    hs.eventtap.keyStroke({}, "down")
end

local function sendUpArrow()
    hs.eventtap.keyStroke({}, "up")
end

hs.hotkey.bind({"cmd", "ctrl", "alt", "shift"}, "j", sendDownArrow)
hs.hotkey.bind({"cmd", "ctrl", "alt", "shift"}, "k", sendUpArrow)
print("Arrow key navigation config created!")
