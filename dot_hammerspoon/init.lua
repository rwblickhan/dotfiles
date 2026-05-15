hs.loadSpoon("EmmyLua")

local function urlEncode(s)
    return s:gsub("([^%w%-%.%_%~ ])", function(c)
        return string.format("%%%02X", string.byte(c))
    end):gsub(" ", "%%20")
end

local function isChromeFocused()
    return hs.application.frontmostApplication():name() == "Google Chrome"
end

local function sendTabToDrafts()
    local script = [[
        tell application "Google Chrome"
            set tabTitle to title of active tab of front window
            set tabURL to URL of active tab of front window
            close active tab of front window
        end tell
        return tabTitle & "|||" & tabURL
    ]]
    local ok, result = hs.osascript.applescript(script)
    if ok then
        local sep = result:find("|||", 1, true)
        local title = result:sub(1, sep - 1)
        local url = result:sub(sep + 3)
        local text = urlEncode("[" .. title .. "](" .. url .. ")")
        hs.urlevent.openURL("drafts://x-callback-url/create?text=" .. text)
        hs.notify.new({ title = "Sent to Drafts", informativeText = title }):send()
        hs.application.launchOrFocus("Google Chrome")
    end
end

local function copyTabAsMarkdown()
    local script = [[
        tell application "Google Chrome"
            set tabTitle to title of active tab of front window
            set tabURL to URL of active tab of front window
        end tell
        return tabTitle & "|||" & tabURL
    ]]
    local ok, result = hs.osascript.applescript(script)
    if ok then
        local sep = result:find("|||", 1, true)
        local title = result:sub(1, sep - 1)
        local url = result:sub(sep + 3)
        hs.pasteboard.setContents("[" .. title .. "](" .. url .. ")")
        hs.notify.new({ title = "Copied", informativeText = title }):send()
    end
end

local function collapseChromeTabs()
    local win = hs.application.get("Google Chrome"):mainWindow()
    if not win then return end

    local function findButton(element)
        for _, label in ipairs({ "Collapse Tabs", "Expand Tabs" }) do
            if element:attributeValue("AXDescription") == label then
                return element
            end
        end
        for _, child in ipairs(element:attributeValue("AXChildren") or {}) do
            local found = findButton(child)
            if found then return found end
        end
    end

    local btn = findButton(hs.axuielement.windowElement(win))
    if btn then
        btn:performAction("AXPress")
    else
        hs.notify.new({ title = "Hammerspoon", informativeText = "Expand / collapse tabs button not found" }):send()
    end
end

local function bindConditionalHotkey(mods, key, condition, fn)
    local hk
    hk = hs.hotkey.bind(mods, key, function()
        if not condition() then
            hk:disable()
            hs.eventtap.keyStroke(mods, key)
            hk:enable()
        else
            fn()
        end
    end)
    return hk
end

local function showOrHide(appName)
    local app = hs.application.get(appName)
    if app and app:isFrontmost() then
        app:hide()
    elseif app then
        app:unhide()
        app:activate()
        local win = app:mainWindow()
        if win then
            win:raise()
        else
            hs.eventtap.keyStroke({"cmd"}, "n")
        end
    else
        hs.application.launchOrFocus(appName)
    end
end

local hyper      = { "cmd", "ctrl", "alt", "shift" }
local modsChrome = { "cmd", "shift" }

-- Arrow key navigation
hs.hotkey.bind(hyper, "j", function() hs.eventtap.keyStroke({}, "down") end)
hs.hotkey.bind(hyper, "k", function() hs.eventtap.keyStroke({}, "up") end)
hs.hotkey.bind(hyper, "h", function() hs.eventtap.keyStroke({}, "left") end)
hs.hotkey.bind(hyper, "l", function() hs.eventtap.keyStroke({}, "right") end)

-- App show/hide hotkeys
hs.hotkey.bind(hyper, "1", function() showOrHide("1Password") end)
hs.hotkey.bind(hyper, "3", function() showOrHide("Music") end)
hs.hotkey.bind(hyper, "8", function() showOrHide("Things3") end)
hs.hotkey.bind(hyper, "a", function() showOrHide("Claude") end)
hs.hotkey.bind(hyper, "b", function() showOrHide("Google Chrome") end)
hs.hotkey.bind(hyper, "c", function() showOrHide("Fantastical") end)
hs.hotkey.bind(hyper, "d", function() showOrHide("Drafts") end)
hs.hotkey.bind(hyper, "e", function() showOrHide("Mimestream") end)
hs.hotkey.bind(hyper, "m", function() showOrHide("Facebook") end)
hs.hotkey.bind(hyper, "n", function() showOrHide("Obsidian") end)
hs.hotkey.bind(hyper, "s", function() showOrHide("Slack") end)
hs.hotkey.bind(hyper, "t", function() showOrHide("Ghostty") end)
hs.hotkey.bind(hyper, "v", function() showOrHide("Visual Studio Code") end)
hs.hotkey.bind(hyper, "x", function() showOrHide("Zed") end)
hs.hotkey.bind(hyper, "z", function() showOrHide("zoom.us") end)
hs.hotkey.bind(hyper, "\\", function() showOrHide("Bloom") end)

-- Chrome-specific hotkeys
bindConditionalHotkey(modsChrome, "d", isChromeFocused, sendTabToDrafts)
bindConditionalHotkey(modsChrome, "l", isChromeFocused, copyTabAsMarkdown)
bindConditionalHotkey(modsChrome, "h", isChromeFocused, collapseChromeTabs)
