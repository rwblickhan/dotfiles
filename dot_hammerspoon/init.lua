hs.loadSpoon("EmmyLua")
hs.loadSpoon("LeftRightHotkey")
spoon.LeftRightHotkey:start()

local function sendDownArrow()
    hs.eventtap.keyStroke({}, "down")
end

local function sendUpArrow()
    hs.eventtap.keyStroke({}, "up")
end

local function sendRightArrow()
    hs.eventtap.keyStroke({}, "right")
end

local function sendLeftArrow()
    hs.eventtap.keyStroke({}, "left")
end

hs.hotkey.bind({ "cmd", "ctrl", "alt", "shift" }, "j", sendDownArrow)
hs.hotkey.bind({ "cmd", "ctrl", "alt", "shift" }, "k", sendUpArrow)
hs.hotkey.bind({ "cmd", "ctrl", "alt", "shift" }, "h", sendLeftArrow)
hs.hotkey.bind({ "cmd", "ctrl", "alt", "shift" }, "l", sendRightArrow)
print("Arrow key navigation config created!")

local function urlEncode(s)
    return s:gsub("([^%w%-%.%_%~ ])", function(c)
        return string.format("%%%02X", string.byte(c))
    end):gsub(" ", "+")
end

hs.hotkey.bind({ "cmd", "shift" }, "d", function()
    if hs.application.frontmostApplication():name() ~= "Google Chrome" then return end
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
        local text = urlEncode(title .. "\n" .. url)
        hs.urlevent.openURL("drafts://x-callback-url/create?text=" .. text)
        hs.notify.new({ title = "Sent to Drafts", informativeText = title }):send()
        hs.application.launchOrFocus("Google Chrome")
    end
end)

hs.hotkey.bind({ "cmd", "shift" }, "h", function()
    if hs.application.frontmostApplication():name() ~= "Google Chrome" then return end
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
end)

hs.hotkey.bind({ "cmd", "shift" }, "l", function()
    if hs.application.frontmostApplication():name() ~= "Google Chrome" then return end
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
end)
