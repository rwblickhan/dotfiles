hs.loadSpoon("EmmyLua")
hs.loadSpoon("LeftRightHotkey")
spoon.LeftRightHotkey:start()

hs.alert.show("Config reloaded", hs.screen.mainScreen())

local hotkeyLogger = hs.logger.new("hotkeys", "debug")

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
    hs.alert.show("Sent to Drafts: " .. title)
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
    hs.alert.show("Copied: " .. title)
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
    hs.alert.show(notFoundMsg)
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

local function focusFacebookMessages()
  local chrome = hs.application.find("Google Chrome")

  local function launchProfile()
    local app = hs.application.open("Google Chrome", 5, true)
    if app then
      app:selectMenuItem({ "Profiles", "Russell (Personal)" })
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
  hotkeyLogger.df("showOrHide %s", appName)
  local app = hs.application.find(appName)
  if app ~= nil and app:isFrontmost() then
    app:hide()
  else
    hs.application.open(appName)
  end
end

local function moveFocusedWindowToUnit(unit)
  local win = hs.window.focusedWindow()
  if win then win:moveToUnit(unit) end
end

local function leftHalf() moveFocusedWindowToUnit({ x = 0, y = 0, w = 0.5, h = 1 }) end

local function rightHalf() moveFocusedWindowToUnit({ x = 0.5, y = 0, w = 0.5, h = 1 }) end

local function maximize()
  local win = hs.window.focusedWindow()
  if win then win:maximize() end
end

-- reasonable size (60% of screen, capped at 1025x900px, centered)
-- matches Raycast: https://manual.raycast.com/window-management#commands
local function reasonableSize()
  local win = hs.window.focusedWindow()
  if not win then return end
  local screenFrame = win:screen():frame()
  local w = math.min(screenFrame.w * 0.6, 1025)
  local h = math.min(screenFrame.h * 0.6, 900)
  win:setFrame({
    x = screenFrame.x + (screenFrame.w - w) / 2,
    y = screenFrame.y + (screenFrame.h - h) / 2,
    w = w,
    h = h,
  })
end

local function nextDisplay()
  local win = hs.window.focusedWindow()
  if win then win:moveToScreen(win:screen():next()) end
end

local function previousDisplay()
  local win = hs.window.focusedWindow()
  if win then win:moveToScreen(win:screen():previous()) end
end

local function emptyTrash()
  hs.task.new("/bin/sh", function(exitCode, _, stdErr)
    if exitCode == 0 then
      hs.alert.show("Trash emptied")
    else
      hs.alert.show("Empty Trash failed: " .. stdErr)
    end
  end, { "-c", "rm -rf ~/.Trash/* ~/.Trash/.[!.]*" }):start()
end

-- Hotkeys

-- Most hotkeys are bound to the right Command key alone, via the
-- LeftRightHotkey Spoon, rather than the full hyper chord
-- (cmd+ctrl+alt+shift). The hyper chord is reserved for right-cmd+f and
-- right-cmd+=, which karabiner-elements still synthesizes into a real
-- Hyper+f / Hyper+= -- those two are consumed directly by third-party apps'
-- own global hotkey listeners (see the "other hotkeys to set up" comment
-- below), outside Hammerspoon's control.

local rightCmd = { "rCmd" }
local rightOpt = { "rAlt" }

-- These are exposed only via the hs.urlevent scheme below (e.g. for Raycast
-- or Shortcuts to trigger), not bound to a hotkey directly.
local windowCommands = {
  { name = "left-half", fn = leftHalf },
  { name = "right-half", fn = rightHalf },
  { name = "maximize", fn = maximize },
  { name = "reasonable-size", fn = reasonableSize },
  { name = "next-display", fn = nextDisplay },
  { name = "previous-display", fn = previousDisplay },
}

for _, cmd in ipairs(windowCommands) do
  hs.urlevent.bind(cmd.name, function() cmd.fn() end)
end

-- Window management: right-opt+h/l move the focused window to the left/right
-- half of the screen, right-opt+j/k maximize it or resize it to a reasonable
-- size, and right-opt+n/p move it to the next/previous display.
local windowModeCommands = {
  { key = "h", fn = leftHalf },
  { key = "l", fn = rightHalf },
  { key = "j", fn = maximize },
  { key = "k", fn = reasonableSize },
  { key = "n", fn = nextDisplay },
  { key = "p", fn = previousDisplay },
}

for _, cmd in ipairs(windowModeCommands) do
  spoon.LeftRightHotkey:bind(rightOpt, cmd.key, cmd.fn)
end

-- right-opt+e = empty trash
spoon.LeftRightHotkey:bind(rightOpt, "e", emptyTrash)

-- App show/hide hotkeys
-- 1 = 1password
spoon.LeftRightHotkey:bind(rightCmd, "1", function() showOrHide("1Password") end)
-- # = Music
spoon.LeftRightHotkey:bind(rightCmd, "3", function() showOrHide("Music") end)
-- * = Things
spoon.LeftRightHotkey:bind(rightCmd, "8", function() showOrHide("com.culturedcode.ThingsMac") end)
-- a = AI
spoon.LeftRightHotkey:bind(rightCmd, "a", function() showOrHide("Claude") end)
-- b = browser
spoon.LeftRightHotkey:bind(rightCmd, "b", function() showOrHide("Google Chrome") end)
-- c = calendar
spoon.LeftRightHotkey:bind(rightCmd, "c", function() showOrHide("Fantastical") end)
-- d = draft
spoon.LeftRightHotkey:bind(rightCmd, "d", function() showOrHide("Drafts") end)
-- e = email
spoon.LeftRightHotkey:bind(rightCmd, "e", function() showOrHide("Mimestream") end)
-- g = Google Search shortcut
spoon.LeftRightHotkey:bind(rightCmd, "g", function()
  hs.task.new("/usr/bin/shortcuts", nil, { "run", "Google Search" }):start()
end)
-- m = messenger
spoon.LeftRightHotkey:bind(rightCmd, "m", focusFacebookMessages)
-- n = notes
spoon.LeftRightHotkey:bind(rightCmd, "n", function() showOrHide("md.obsidian") end)
-- r = reload hammerspoon
spoon.LeftRightHotkey:bind(rightCmd, "r", hs.reload)
-- s = slack
spoon.LeftRightHotkey:bind(rightCmd, "s", function() showOrHide("Slack") end)
-- t = terminal
spoon.LeftRightHotkey:bind(rightCmd, "t", function() showOrHide("Ghostty") end)
-- v = vs code
spoon.LeftRightHotkey:bind(rightCmd, "v", function() showOrHide("Visual Studio Code") end)
-- w = Wikipedia Search shortcut
spoon.LeftRightHotkey:bind(rightCmd, "w", function()
  hs.task.new("/usr/bin/shortcuts", nil, { "run", "Wikipedia Search" }):start()
end)
-- z = zoom
spoon.LeftRightHotkey:bind(rightCmd, "z", function() showOrHide("zoom.us") end)
-- / = files
spoon.LeftRightHotkey:bind(rightCmd, "/", function() showOrHide("Bloom") end)

-- ins = edit clipboard in Helix
hs.hotkey.bind({}, "help", hxClipboard)
-- delete = edit clipboard in Helix
spoon.LeftRightHotkey:bind(rightCmd, "delete", hxClipboard)

-- other hotkeys to set up
-- right-cmd+= (karabiner-synthesized as Hyper+=) - QuickSoulver in Soulver 3
-- right-cmd+f (karabiner-synthesized as Hyper+f) - global search in Bloom
-- command+shift+v - open quick menu in Pastebot
-- ctrl+option+v - paste with last filter in Pastebot
-- cmd+shift+2 - capture history in CleanShot X
-- cmd+shift+4 - capture area in CleanShot X
-- cmd+shift+5 - all-in-one in CleanShot X

-- Drafts-specific hotkeys
bindConditionalHotkey({ "ctrl", "cmd" }, "l", isDraftsFocused, function() selectMenuItem("Drafts", "Link Mode") end)
bindConditionalHotkey({ "ctrl", "cmd" }, "k", isDraftsFocused, function() selectMenuItem("Drafts", "Kebab Case") end)
bindConditionalHotkey({ "ctrl", "cmd" }, "t", isDraftsFocused, function() selectMenuItem("Drafts", "Title Case") end)
bindConditionalHotkey({ "ctrl" }, "o", isDraftsFocused, function() selectMenuItem("Drafts", "Open Link") end)
bindConditionalHotkey({ "ctrl" }, "g", isDraftsFocused, function() selectMenuItem("Drafts", "Send to GoodLinks") end)
bindConditionalHotkey({ "ctrl" }, "t", isDraftsFocused, function() selectMenuItem("Drafts", "Task in Things") end)

-- Chrome-specific hotkeys
bindConditionalHotkey({ "cmd" }, "d", isChromeFocused, openChromeTabInSplitView)
bindConditionalHotkey({ "cmd", "shift" }, "d", isChromeFocused, sendTabToDrafts)
bindConditionalHotkey({ "cmd", "shift" }, "l", isChromeFocused, copyTabAsMarkdown)
bindConditionalHotkey({ "cmd", "shift" }, "h", isChromeFocused, collapseChromeTabs)
