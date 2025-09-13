hs.loadSpoon("EmmyLua")
hs.loadSpoon("LeftRightHotkey")
spoon.LeftRightHotkey:start()

local function typeCheckbox()
    hs.eventtap.keyStrokes("- [x]")
end

spoon.LeftRightHotkey:bind({ "rOpt" }, "x", typeCheckbox)
print("Markdown checkbox config created!")
