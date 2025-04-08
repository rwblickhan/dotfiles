hs.hotkey.bind({"rightCtrl"}, "x", function()
    hs.eventtap.keyStrokes("- [x]")
end)
hs.hotkey.bind({"rightAlt"}, "x", function()
    hs.eventtap.keyStrokes("- [x]")
end)

print("Markdown checkbox config created!")
