-- Quick switcher, mimicking Raycast's root search: fuzzy-find applications,
-- System Settings panes, and Index's quicklinks and search engines.
--
-- Quicklinks and search engines are read from Index's TOML export
-- (~/.config/index/settings.toml), and the parsing, placeholder expansion,
-- trigger, fuzzy-matching and frecency logic is ported from Index:
-- https://github.com/rwblickhan/index

local webchooser = require("webchooser")

local M = {}

local logger = hs.logger.new("switcher", "info")

local home = os.getenv("HOME")
local indexSettingsPath = home .. "/.config/index/settings.toml"
local usageSettingsKey = "quickSwitcherUsage"
local fallbackTrigger = "g"

-- Index's TOMLSettingsCodec: a purpose-built subset of TOML (arrays of tables
-- of quoted string keys), not a general-purpose parser.

local tomlEscapes = { ['"'] = '"', ["\\"] = "\\", n = "\n", r = "\r", t = "\t", b = "\b", f = "\f" }

local function parseTomlString(rest)
  local out = {}
  local i = 1
  while i <= #rest do
    local c = rest:sub(i, i)
    if c == "\\" and i < #rest then
      local nextChar = rest:sub(i + 1, i + 1)
      local hex = rest:sub(i + 2, i + 5)
      if tomlEscapes[nextChar] then
        table.insert(out, tomlEscapes[nextChar])
        i = i + 2
      elseif nextChar == "u" and hex:match("^%x%x%x%x$") then
        table.insert(out, utf8.char(tonumber(hex, 16)))
        i = i + 6
      else
        table.insert(out, nextChar)
        i = i + 2
      end
    elseif c == '"' then
      return table.concat(out)
    else
      table.insert(out, c)
      i = i + 1
    end
  end
  return nil
end

local function trim(s)
  return s:match("^%s*(.-)%s*$")
end

local function decodeIndexSettings(text)
  local links, engines = {}, {}
  local currentTable, fields = nil, {}

  local function flush()
    if currentTable == "links" then
      if fields.title and fields.url_template then
        table.insert(links, { title = fields.title, urlTemplate = fields.url_template })
      else
        logger.wf("Skipping [[links]] entry missing title or url_template")
      end
    elseif currentTable == "search_engines" then
      if fields.title and fields.trigger and fields.url_template then
        table.insert(engines, { title = fields.title, trigger = fields.trigger, urlTemplate = fields.url_template })
      else
        logger.wf("Skipping [[search_engines]] entry missing title, trigger or url_template")
      end
    end
    fields = {}
  end

  for rawLine in (text .. "\n"):gmatch("([^\n]*)\n") do
    local line = trim(rawLine)
    if line == "" or line:sub(1, 1) == "#" then
      -- skip
    elseif line:match("^%[%[.*%]%]$") then
      flush()
      currentTable = trim(line:sub(3, -3))
    elseif line:match("^%[.*%]$") then
      flush()
      currentTable = nil
    elseif currentTable then
      local key, rest = line:match('^([^=]-)%s*=%s*"(.*)$')
      local value = rest and parseTomlString(rest)
      if value then fields[trim(key)] = value end
    end
  end
  flush()
  return links, engines
end

-- Index's PlaceholderExpander: {{clipboard}}, {{uuid}}, and
-- {{date|time|datetime|day format="..." offset="..."}}, each optionally piped
-- through modifiers, e.g. {{clipboard | trim | percent-encode}}.
-- Date formats use DateFormatter (ICU) pattern syntax, e.g. "yyyy-MM-dd".
-- The tz and locale attributes aren't supported.

local function percentEncode(s)
  return (s:gsub("[^%w%-%._~]", function(c) return string.format("%%%02X", c:byte()) end))
end

local function splitTopLevel(s, separator)
  local parts, current, inQuotes = {}, {}, false
  for c in s:gmatch(".") do
    if c == '"' then
      inQuotes = not inQuotes
      table.insert(current, c)
    elseif c == separator and not inQuotes then
      table.insert(parts, table.concat(current))
      current = {}
    else
      table.insert(current, c)
    end
  end
  table.insert(parts, table.concat(current))
  return parts
end

local function parseNameAndAttributes(s)
  local tokens = splitTopLevel(s, " ")
  local name, attributes = nil, {}
  for _, token in ipairs(tokens) do
    if token ~= "" then
      if not name then
        name = token:lower()
      else
        local key, value = token:match("^([^=]+)=(.*)$")
        if key then
          attributes[key] = value:match('^"(.*)"$') or value
        end
      end
    end
  end
  return name or "", attributes
end

local offsetUnits = { s = "sec", m = "min", h = "hour", d = "day", M = "month", y = "year" }

local function offsetTime(time, offset)
  local sign, amount, unit = offset:match("^([+-]?)(%d+)(%a)$")
  if not amount then return time end
  local value = tonumber(amount) * (sign == "-" and -1 or 1)
  local t = os.date("*t", time)
  t.isdst = nil
  if unit == "w" then
    t.day = t.day + 7 * value
  elseif offsetUnits[unit] then
    t[offsetUnits[unit]] = t[offsetUnits[unit]] + value
  else
    return time
  end
  return os.time(t)
end

local function formatICUDate(pattern, time)
  local t = os.date("*t", time)
  local hour12 = (t.hour % 12 == 0) and 12 or t.hour % 12
  local function field(letter, count)
    if letter == "y" then return count == 2 and os.date("%y", time) or tostring(t.year) end
    if letter == "M" or letter == "L" then
      if count >= 4 then return os.date("%B", time) end
      if count == 3 then return os.date("%b", time) end
      return count == 2 and string.format("%02d", t.month) or tostring(t.month)
    end
    if letter == "d" then return count == 2 and string.format("%02d", t.day) or tostring(t.day) end
    if letter == "E" then return count >= 4 and os.date("%A", time) or os.date("%a", time) end
    if letter == "H" then return count == 2 and string.format("%02d", t.hour) or tostring(t.hour) end
    if letter == "h" then return count == 2 and string.format("%02d", hour12) or tostring(hour12) end
    if letter == "m" then return count == 2 and string.format("%02d", t.min) or tostring(t.min) end
    if letter == "s" then return count == 2 and string.format("%02d", t.sec) or tostring(t.sec) end
    if letter == "a" then return t.hour < 12 and "AM" or "PM" end
    return string.rep(letter, count)
  end

  local out, i = {}, 1
  while i <= #pattern do
    local c = pattern:sub(i, i)
    if c == "'" then
      if pattern:sub(i + 1, i + 1) == "'" then
        table.insert(out, "'")
        i = i + 2
      else
        local close = pattern:find("'", i + 1, true) or (#pattern + 1)
        table.insert(out, pattern:sub(i + 1, close - 1))
        i = close + 1
      end
    elseif c:match("%a") then
      local j = i
      while pattern:sub(j + 1, j + 1) == c do j = j + 1 end
      table.insert(out, field(c, j - i + 1))
      i = j + 1
    else
      table.insert(out, c)
      i = i + 1
    end
  end
  return table.concat(out)
end

local defaultDateFormats = {
  date = "MMM d, y",
  time = "h:mm a",
  datetime = "MMM d, y 'at' h:mm a",
  day = "EEEE",
}

local function resolvePlaceholder(name, attributes)
  if name == "clipboard" then return hs.pasteboard.getContents() or "" end
  if name == "uuid" then return hs.host.uuid() end
  if defaultDateFormats[name] then
    local time = os.time()
    if attributes.offset then time = offsetTime(time, attributes.offset) end
    return formatICUDate(attributes.format or defaultDateFormats[name], time)
  end
  return nil
end

local function jsonStringify(s)
  local escapes = { ['"'] = '\\"', ["\\"] = "\\\\", ["\n"] = "\\n", ["\r"] = "\\r", ["\t"] = "\\t" }
  return '"' .. s:gsub('["\\\n\r\t]', escapes) .. '"'
end

local modifiers = {
  uppercase = string.upper,
  lowercase = string.lower,
  capitalize = function(s) return (s:lower():gsub("%f[%w]%w", string.upper)) end,
  trim = trim,
  ["percent-encode"] = percentEncode,
  ["json-stringify"] = jsonStringify,
}

local function expandPlaceholder(content)
  local parts = splitTopLevel(content, "|")
  local name, attributes = parseNameAndAttributes(trim(parts[1]))
  local value = resolvePlaceholder(name, attributes)
  if not value then return nil end
  for i = 2, #parts do
    local modifier = modifiers[trim(parts[i])]
    if modifier then value = modifier(value) end
  end
  return value
end

local function expandPlaceholders(text)
  local out, i = {}, 1
  while i <= #text do
    local three = text:sub(i, i + 2)
    if three == "\\{{" then
      table.insert(out, "{{")
      i = i + 3
    elseif three == "\\}}" then
      table.insert(out, "}}")
      i = i + 3
    else
      local expanded, close
      if text:sub(i, i + 1) == "{{" then
        close = text:find("}}", i + 2, true)
        if close then expanded = expandPlaceholder(text:sub(i + 2, close - 1)) end
      end
      if expanded then
        table.insert(out, expanded)
        i = close + 2
      else
        table.insert(out, text:sub(i, i))
        i = i + 1
      end
    end
  end
  return table.concat(out)
end

local function searchURL(engine, query)
  local encoded = percentEncode(query)
  return (expandPlaceholders(engine.urlTemplate):gsub("%%s", function() return encoded end))
end

-- Index's ranking: a greedy subsequence match rewarding consecutive runs,
-- multiplied by (1 + frecency).

local function fuzzyScore(query, target)
  if query == "" then return 1 end
  query, target = query:lower(), target:lower()
  local qi, consecutive, score = 1, 0, 0
  for ti = 1, #target do
    if qi > #query then break end
    if target:byte(ti) == query:byte(qi) then
      qi = qi + 1
      consecutive = consecutive + 1
      score = score + consecutive
    else
      consecutive = 0
    end
  end
  if qi <= #query then return nil end
  return score / #target
end

local function frecencyScore(entry)
  if not entry then return 0 end
  local hoursSinceUse = (os.time() - entry.lastUsed) / 3600
  local recency = 1 / (1 + hoursSinceUse / 24)
  return entry.count * 0.6 + recency * 0.4
end

local function recordUse(key)
  local usage = hs.settings.get(usageSettingsKey) or {}
  local entry = usage[key] or { count = 0, lastUsed = 0 }
  entry.count = entry.count + 1
  entry.lastUsed = os.time()
  usage[key] = entry
  hs.settings.set(usageSettingsKey, usage)
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

local indexCache = { modified = nil, links = {}, engines = {} }

local function loadIndexSettings()
  local modified = hs.fs.attributes(indexSettingsPath, "modification")
  if not modified then
    logger.wf("Index settings not found at %s", indexSettingsPath)
    return {}, {}
  end
  if modified ~= indexCache.modified then
    local file = io.open(indexSettingsPath, "r")
    if file then
      indexCache.links, indexCache.engines = decodeIndexSettings(file:read("a"))
      indexCache.modified = modified
      file:close()
    end
  end
  return indexCache.links, indexCache.engines
end

local function indexItems()
  local links, engines = loadIndexSettings()
  local items, engineItems = {}, {}
  for _, link in ipairs(links) do
    table.insert(items, {
      key = "link:" .. link.title,
      title = link.title,
      subText = "Quicklink · " .. link.urlTemplate,
      image = urlHandlerIcon(link.urlTemplate),
      kind = "link",
      link = link,
    })
  end
  for _, engine in ipairs(engines) do
    local item = {
      key = "engine:" .. engine.trigger,
      title = engine.title,
      subText = "Search Engine · " .. engine.trigger,
      image = urlHandlerIcon(engine.urlTemplate),
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
  for _, item in ipairs(items) do item.frecency = frecencyScore(usage[item.key]) end
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
  local trimmed = trim(query)
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
    local score = fuzzyScore(query, item.title)
    for _, keyword in ipairs(item.keywords or {}) do
      local keywordScore = fuzzyScore(query, keyword)
      if keywordScore and (not score or keywordScore > score) then score = keywordScore end
    end
    if score then
      table.insert(scored, { item = item, rank = query == "" and item.frecency or score * (1 + item.frecency) })
    end
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

local function showWithQuery(query)
  allItems = buildItems()
  chooser:query(query)
  chooser:show()
end

local function activate(result)
  local item = result.item
  if item.kind == "app" then
    recordUse(item.key)
    hs.application.launchOrFocus(item.path)
  elseif item.kind == "settings" then
    recordUse(item.key)
    openURL(item.url)
  elseif item.kind == "link" then
    recordUse(item.key)
    openURL(expandPlaceholders(item.link.urlTemplate))
  elseif item.kind == "engine" then
    if result.query then
      recordUse(item.key)
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

-- Warm the application icon cache so the first show isn't slow.
hs.timer.doAfter(1, function() applicationItems() end)

return M
