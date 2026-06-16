hs.loadSpoon("EmmyLua")

local function urlEncode(s)
  return s:gsub("([^%w%-%.%_%~ ])", function(c)
    return string.format("%%%02X", string.byte(c))
  end):gsub(" ", "%%20")
end

local function isChromeFocused()
  return hs.application.frontmostApplication():name() == "Google Chrome"
end

local function isDraftsFocused()
  return hs.application.frontmostApplication():name() == "Drafts"
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

local function selectMenuItem(appName, item)
  local app = hs.application.find(appName)
  if app then app:selectMenuItem(item) end
end

local function clickAppButton(appName, matchFn, notFoundMsg)
  local app = hs.application.get(appName)
  if not app then return end
  local win = app:mainWindow()
  if not win then return end

  local function findButton(element)
    if matchFn(element:attributeValue("AXDescription") or "") then
      return element
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
    hs.notify.new({ title = "Hammerspoon", informativeText = notFoundMsg }):send()
  end
end

local function openChromeTabInSplitView()
  clickAppButton("Google Chrome",
    function(desc) return desc:lower():find("split view", 1, true) end,
    "Split view button not found"
  )
end

local function collapseChromeTabs()
  clickAppButton("Google Chrome",
    function(desc) return desc == "Collapse Tabs" or desc == "Expand Tabs" end,
    "Expand / collapse tabs button not found"
  )
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

local chromePersonalProfileDir = (function()
  local path = os.getenv("HOME") .. "/Library/Application Support/Google/Chrome/Local State"
  local f = io.open(path, "r")
  if not f then return nil end
  local state = hs.json.decode(f:read("*a"))
  f:close()
  if not (state and state.profile and state.profile.info_cache) then return nil end
  for dir, info in pairs(state.profile.info_cache) do
    if info.name == "Personal" then return dir end
  end
end)()

local function focusFacebookMessages()
  local chrome = hs.application.find("Google Chrome")

  local function launchProfile()
    if chromePersonalProfileDir then
      hs.execute(string.format("open -na 'Google Chrome' --args --profile-directory='%s'", chromePersonalProfileDir))
    else
      hs.application.open("Google Chrome")
    end
  end

  if not chrome or not chrome:isRunning() then
    launchProfile()
    return
  end

  if chrome:isFrontmost() then
    local ok, url = hs.osascript.applescript([[
      tell application "Google Chrome"
        if (count of windows) > 0 then
          return URL of active tab of front window
        else
          return ""
        end if
      end tell
    ]])
    if ok and type(url) == "string" and url:find("facebook.com/messages", 1, true) then
      chrome:hide()
      return
    end
  end

  -- The Personal profile always keeps Messenger as its first tab, so find the
  -- window whose first tab is Messenger, switch to that tab, and raise it.
  local ok, found = hs.osascript.applescript([[
    tell application "Google Chrome"
      repeat with w in windows
        if (count of tabs of w) > 0 and (URL of tab 1 of w contains "facebook.com/messages") then
          set active tab index of w to 1
          set index of w to 1
          activate
          return "yes"
        end if
      end repeat
      return "no"
    end tell
  ]])

  if not (ok and found == "yes") then
    launchProfile()
  end
end

local function hxClipboard()
  hs.task.new(os.getenv("HOME") .. "/.local/bin/hxclip", nil):start()
end

local function showOrHide(appName)
  local app = hs.application.find(appName)
  if app ~= nil and app:isFrontmost() then
    app:hide()
  else
    hs.application.open(appName)
  end
end

local hyper = { "cmd", "ctrl", "alt", "shift" }

-- Arrow key navigation
hs.hotkey.bind(hyper, "j", function() hs.eventtap.keyStroke({}, "down") end)
hs.hotkey.bind(hyper, "k", function() hs.eventtap.keyStroke({}, "up") end)
hs.hotkey.bind(hyper, "h", function() hs.eventtap.keyStroke({}, "left") end)
hs.hotkey.bind(hyper, "l", function() hs.eventtap.keyStroke({}, "right") end)

-- App show/hide hotkeys
-- 1 = 1password
hs.hotkey.bind(hyper, "1", function() showOrHide("1Password") end)
-- # = Music
hs.hotkey.bind(hyper, "3", function() showOrHide("Music") end)
-- * = Things
hs.hotkey.bind(hyper, "8", function() showOrHide("com.culturedcode.ThingsMac") end)
-- a = AI
hs.hotkey.bind(hyper, "a", function() showOrHide("Claude") end)
-- b = browser
hs.hotkey.bind(hyper, "b", function() showOrHide("Google Chrome") end)
-- c = calendar
hs.hotkey.bind(hyper, "c", function() showOrHide("Fantastical") end)
-- d = draft
hs.hotkey.bind(hyper, "d", function() showOrHide("Drafts") end)
-- e = email
hs.hotkey.bind(hyper, "e", function() showOrHide("Mimestream") end)
-- m = messenger
hs.hotkey.bind(hyper, "m", focusFacebookMessages)
-- n = notes
hs.hotkey.bind(hyper, "n", function() showOrHide("Obsidian") end)
-- r = reload hammerspoon
hs.hotkey.bind(hyper, "r", function()
  hs.notify.new({ title = "Hammerspoon", informativeText = "Config reloaded" }):send()
  hs.reload()
end)
-- s = slack
hs.hotkey.bind(hyper, "s", function() showOrHide("Slack") end)
-- t = terminal
hs.hotkey.bind(hyper, "t", function() showOrHide("Ghostty") end)
-- v = vs code
hs.hotkey.bind(hyper, "v", function() showOrHide("Visual Studio Code") end)
-- z = zoom
hs.hotkey.bind(hyper, "z", function() showOrHide("zoom.us") end)
-- / = files
hs.hotkey.bind(hyper, "/", function() showOrHide("Bloom") end)

-- f1 = Activity Monitor
hs.hotkey.bind({}, "f1", function() showOrHide("Activity Monitor") end)

-- f2 = ona layout
hs.hotkey.bind({}, "f2", function()
  hs.osascript.applescriptFromFile(os.getenv("HOME") .. "/Library/Scripts/ona_layout.applescript")
end)

-- ins = edit clipboard in Helix
hs.hotkey.bind({}, "help", hxClipboard)

-- Drafts-specific hotkeys
bindConditionalHotkey({ "ctrl", "cmd" }, "l", isDraftsFocused, function() selectMenuItem("Drafts", "Link Mode") end)
bindConditionalHotkey({ "ctrl", "cmd" }, "k", isDraftsFocused, function() selectMenuItem("Drafts", "Kebab Case") end)
bindConditionalHotkey({ "ctrl", "cmd" }, "t", isDraftsFocused, function() selectMenuItem("Drafts", "Title Case") end)

-- Chrome-specific hotkeys
bindConditionalHotkey({ "cmd" }, "d", isChromeFocused, openChromeTabInSplitView)
bindConditionalHotkey({ "cmd", "shift" }, "d", isChromeFocused, sendTabToDrafts)
bindConditionalHotkey({ "cmd", "shift" }, "l", isChromeFocused, copyTabAsMarkdown)
bindConditionalHotkey({ "cmd", "shift" }, "h", isChromeFocused, collapseChromeTabs)
