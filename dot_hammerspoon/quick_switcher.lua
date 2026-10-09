-- Quick switcher, mimicking Raycast's root search: fuzzy-find applications,
-- System Settings panes, and Index's quicklinks and search engines.

local index = require("index")
local webchooser = require("webchooser")

local M = {}

local home = os.getenv("HOME")
local usageSettingsKey = "quickSwitcherUsage"
local fallbackTrigger = "g"

local function searchURL(engine, query)
  local encoded = index.percentEncode(query)
  return (index.expandPlaceholders(engine.urlTemplate):gsub("%%s", function() return encoded end))
end

-- Sources

local applicationDirectories = {
  "/Applications",
  "/System/Applications",
  "/System/Library/CoreServices/Applications",
  home .. "/Applications",
}

local extraApplications = { "/System/Library/CoreServices/Finder.app" }

local iconCache = {}

local function cachedIcon(key, loader)
  if iconCache[key] == nil then iconCache[key] = loader() or false end
  return iconCache[key] or nil
end

local function scanApplications(dir, depth, seen, out)
  if not hs.fs.attributes(dir, "mode") then return end
  for name in hs.fs.dir(dir) do
    if name:sub(1, 1) ~= "." then
      local path = dir .. "/" .. name
      if name:match("%.app$") then
        if not seen[path] then
          seen[path] = true
          table.insert(out, path)
        end
      elseif depth > 0 and hs.fs.attributes(path, "mode") == "directory" then
        scanApplications(path, depth - 1, seen, out)
      end
    end
  end
end

local function applicationItems()
  local seen, paths = {}, {}
  for _, dir in ipairs(applicationDirectories) do scanApplications(dir, 1, seen, paths) end
  for _, path in ipairs(extraApplications) do
    if not seen[path] then table.insert(paths, path) end
  end
  local items = {}
  for _, path in ipairs(paths) do
    table.insert(items, {
      key = "app:" .. path,
      title = path:match("([^/]+)%.app$"),
      subText = "Application",
      image = cachedIcon(path, function() return hs.image.iconForFile(path) end),
      kind = "app",
      path = path,
    })
  end
  return items
end

local settingsPanes = {
  { "About", "com.apple.SystemProfiler.AboutExtension", { "system information", "serial number" } },
  { "Accessibility", "com.apple.Accessibility-Settings.extension" },
  { "AirDrop & Handoff", "com.apple.AirDrop-Handoff-Settings.extension" },
  { "Appearance", "com.apple.Appearance-Settings.extension", { "dark mode", "light mode", "accent color" } },
  { "Apple Account", "com.apple.systempreferences.AppleIDSettings", { "icloud", "apple id" } },
  { "Apple Intelligence & Siri", "com.apple.Siri-Settings.extension" },
  { "AppleCare & Warranty", "com.apple.Coverage-Settings.extension" },
  { "Battery", "com.apple.Battery-Settings.extension", { "power", "energy" } },
  { "Bluetooth", "com.apple.BluetoothSettings" },
  { "Date & Time", "com.apple.Date-Time-Settings.extension", { "clock", "time zone" } },
  { "Desktop & Dock", "com.apple.Desktop-Settings.extension", { "mission control", "hot corners", "stage manager" } },
  { "Device Management", "com.apple.Profiles-Settings.extension", { "profiles", "mdm" } },
  { "Displays", "com.apple.Displays-Settings.extension", { "monitor", "resolution", "night shift" } },
  { "Family", "com.apple.Family-Settings.extension" },
  { "Focus", "com.apple.Focus-Settings.extension", { "do not disturb" } },
  { "Game Center", "com.apple.Game-Center-Settings.extension" },
  { "Game Controllers", "com.apple.Game-Controller-Settings.extension" },
  { "General", "com.apple.systempreferences.GeneralSettings" },
  { "Headphones", "com.apple.HeadphoneSettings", { "airpods" } },
  { "Internet Accounts", "com.apple.Internet-Accounts-Settings.extension", { "email accounts" } },
  { "Keyboard", "com.apple.Keyboard-Settings.extension", { "shortcuts", "input sources", "dictation" } },
  { "Language & Region", "com.apple.Localization-Settings.extension" },
  { "Lock Screen", "com.apple.Lock-Screen-Settings.extension", { "screen saver" } },
  { "Login Items & Extensions", "com.apple.LoginItems-Settings.extension", { "startup items" } },
  { "Menu Bar", "com.apple.ControlCenter-Settings.extension", { "control center" } },
  { "Mouse", "com.apple.Mouse-Settings.extension" },
  { "Network", "com.apple.Network-Settings.extension", { "ethernet", "firewall" } },
  { "Notifications", "com.apple.Notifications-Settings.extension" },
  { "Printers & Scanners", "com.apple.Print-Scan-Settings.extension" },
  { "Privacy & Security", "com.apple.settings.PrivacySecurity.extension", { "permissions", "filevault", "accessibility access" } },
  { "Screen Time", "com.apple.Screen-Time-Settings.extension" },
  { "Sharing", "com.apple.Sharing-Settings.extension", { "computer name", "screen sharing", "remote login" } },
  { "Software Update", "com.apple.Software-Update-Settings.extension" },
  { "Sound", "com.apple.Sound-Settings.extension", { "volume", "audio", "output", "input" } },
  { "Spotlight", "com.apple.Spotlight-Settings.extension" },
  { "Startup Disk", "com.apple.Startup-Disk-Settings.extension" },
  { "Storage", "com.apple.settings.Storage", { "disk space" } },
  { "Time Machine", "com.apple.Time-Machine-Settings.extension", { "backup" } },
  { "Touch ID & Password", "com.apple.Touch-ID-Settings.extension", { "fingerprint" } },
  { "Trackpad", "com.apple.Trackpad-Settings.extension", { "gestures" } },
  { "Transfer or Reset", "com.apple.Transfer-Reset-Settings.extension", { "erase" } },
  { "Users & Groups", "com.apple.Users-Groups-Settings.extension" },
  { "VPN", "com.apple.NetworkExtensionSettingsUI.NESettingsUIExtension" },
  { "Wallet & Apple Pay", "com.apple.WalletSettingsExtension" },
  { "Wallpaper", "com.apple.Wallpaper-Settings.extension", { "background" } },
  { "Wi-Fi", "com.apple.wifi-settings-extension", { "wifi", "wireless" } },
}

local function settingsItems()
  local icon = cachedIcon("com.apple.systempreferences", function()
    return hs.image.imageFromAppBundle("com.apple.systempreferences")
  end)
  local items = {}
  for _, pane in ipairs(settingsPanes) do
    table.insert(items, {
      key = "settings:" .. pane[2],
      title = pane[1],
      keywords = pane[3],
      subText = "System Settings",
      image = icon,
      kind = "settings",
      url = "x-apple.systempreferences:" .. pane[2],
    })
  end
  return items
end

local function urlScheme(url)
  return url:match("^([%a][%w+.-]*):")
end

-- hs.urlevent.openURL rejects URLs without "://", such as
-- x-apple.systempreferences: and mailto: URLs.
local function openURL(url)
  local scheme = urlScheme(url)
  local bundleID = scheme and hs.urlevent.getDefaultHandler(scheme)
  if bundleID then
    hs.urlevent.openURLWithBundle(url, bundleID)
  else
    hs.alert.show("No app can open " .. url)
  end
end

local function urlHandlerIcon(template)
  local scheme = urlScheme(template) or "https"
  return cachedIcon("scheme:" .. scheme, function()
    local bundleID = hs.urlevent.getDefaultHandler(scheme)
    return bundleID and hs.image.imageFromAppBundle(bundleID)
  end)
end

local faviconDirectory = home .. "/Library/Caches/org.hammerspoon.Hammerspoon/favicons"
local faviconRequested = {}
local faviconLoaded

local function faviconHost(template)
  local host = template:match("^https?://([^/?#]+)")
  if host and host:match("^[%w.-]+$") then return host:lower() end
end

local function favicon(host)
  local path = faviconDirectory .. "/" .. host .. ".png"
  local icon = cachedIcon("favicon:" .. host, function()
    return hs.fs.attributes(path, "mode") and hs.image.imageFromPath(path)
  end)
  if not icon and not faviconRequested[host] then
    faviconRequested[host] = true
    hs.http.asyncGet("https://www.google.com/s2/favicons?sz=64&domain=" .. host, nil, function(status, body)
      if status ~= 200 then return end
      hs.fs.mkdir(faviconDirectory)
      local file = io.open(path, "wb")
      if not file then return end
      file:write(body)
      file:close()
      local image = hs.image.imageFromPath(path)
      if not image then
        os.remove(path)
        return
      end
      iconCache["favicon:" .. host] = image
      faviconLoaded(host, image)
    end)
  end
  return icon
end

local function urlIcon(template)
  local host = faviconHost(template)
  return host and favicon(host) or urlHandlerIcon(template)
end

local function indexItems()
  local links, engines = index.loadSettings()
  local items, engineItems = {}, {}
  for _, link in ipairs(links) do
    table.insert(items, {
      key = "link:" .. link.title,
      title = link.title,
      subText = "Quicklink · " .. link.urlTemplate,
      image = urlIcon(link.urlTemplate),
      faviconHost = faviconHost(link.urlTemplate),
      kind = "link",
      link = link,
    })
  end
  for _, engine in ipairs(engines) do
    local item = {
      key = "engine:" .. engine.trigger,
      title = engine.title,
      subText = "Search Engine · " .. engine.trigger,
      image = urlIcon(engine.urlTemplate),
      faviconHost = faviconHost(engine.urlTemplate),
      kind = "engine",
      engine = engine,
    }
    table.insert(items, item)
    engineItems[engine.trigger:lower()] = item
  end
  return items, engineItems
end

-- Chooser

local allItems = {}
local enginesByTrigger = {}
local results = {}

local function withFrecency(items)
  local usage = hs.settings.get(usageSettingsKey) or {}
  for _, item in ipairs(items) do item.frecency = index.frecencyScore(usage[item.key]) end
  return items
end

local function buildItems()
  local items = {}
  local linkAndEngineItems
  linkAndEngineItems, enginesByTrigger = indexItems()
  for _, source in ipairs({ applicationItems(), settingsItems(), linkAndEngineItems }) do
    for _, item in ipairs(source) do table.insert(items, item) end
  end
  return withFrecency(items)
end

local function triggeredSearch(query)
  local trigger, rest = query:match("^(%S+) (.*)$")
  local item = trigger and enginesByTrigger[trigger:lower()]
  if item then return item, rest end
end

local function engineSearchResult(item, query)
  local trimmed = index.trim(query)
  if trimmed == "" then
    return { item = item, text = item.title, subText = "Type a query to search", image = item.image }
  end
  return {
    item = item,
    query = trimmed,
    text = string.format('Search %s for "%s"', item.title, trimmed),
    subText = item.subText,
    image = item.image,
  }
end

local function search(query)
  local engineItem, engineQuery = triggeredSearch(query)
  if engineItem then return { engineSearchResult(engineItem, engineQuery) } end

  local scored = {}
  for _, item in ipairs(allItems) do
    local rank = index.rank(query, item.title, item.engine and item.engine.trigger, item.frecency)
    for _, keyword in ipairs(item.keywords or {}) do
      local keywordRank = index.rank(query, keyword, nil, item.frecency)
      if keywordRank and (not rank or keywordRank > rank) then rank = keywordRank end
    end
    if rank then table.insert(scored, { item = item, rank = rank }) end
  end
  table.sort(scored, function(a, b)
    if a.rank == b.rank then return a.item.title:lower() < b.item.title:lower() end
    return a.rank > b.rank
  end)

  local out = {}
  for _, s in ipairs(scored) do
    table.insert(out, { item = s.item, text = s.item.title, subText = s.item.subText, image = s.item.image })
  end
  local fallback = enginesByTrigger[fallbackTrigger]
  if query ~= "" and fallback then table.insert(out, engineSearchResult(fallback, query)) end
  return out
end

local chooser

local function refresh(query)
  results = search(query or "")
  local choices = {}
  for i, r in ipairs(results) do
    choices[i] = { text = r.text, subText = r.subText, image = r.image, id = i }
  end
  chooser:choices(choices)
end

faviconLoaded = function(host, image)
  for _, item in ipairs(allItems) do
    if item.faviconHost == host then item.image = image end
  end
  if chooser:isVisible() then refresh(chooser:query()) end
end

local function showWithQuery(query)
  allItems = buildItems()
  chooser:query(query)
  chooser:show()
end

local function activate(result)
  local item = result.item
  if item.kind == "app" then
    index.recordUse(usageSettingsKey, item.key)
    hs.application.launchOrFocus(item.path)
  elseif item.kind == "settings" then
    index.recordUse(usageSettingsKey, item.key)
    openURL(item.url)
  elseif item.kind == "link" then
    index.recordUse(usageSettingsKey, item.key)
    openURL(index.expandPlaceholders(item.link.urlTemplate))
  elseif item.kind == "engine" then
    if result.query then
      index.recordUse(usageSettingsKey, item.key)
      openURL(searchURL(item.engine, result.query))
    else
      hs.timer.doAfter(0, function() showWithQuery(item.engine.trigger .. " ") end)
    end
  end
end

chooser = webchooser.new(function(choice)
  if not choice then return end
  local result = results[choice.id]
  if result then activate(result) end
end)
chooser:placeholderText("Search apps, settings, quicklinks and search engines…")
chooser:queryChangedCallback(refresh)

function M.show()
  showWithQuery("")
end

-- Warm the application icon and favicon caches so the first show isn't slow.
hs.timer.doAfter(1, function()
  applicationItems()
  indexItems()
end)

return M
