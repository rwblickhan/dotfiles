-- Shared access to Index's settings and logic, for the quick switcher and
-- snippet picker.
--
-- Quicklinks, search engines and snippets are read from Index's TOML export
-- (~/.config/index/settings.toml), and the parsing, placeholder expansion,
-- fuzzy-matching and frecency logic is ported from Index:
-- https://github.com/rwblickhan/index

local M = {}

local logger = hs.logger.new("index", "info")

local settingsPath = os.getenv("HOME") .. "/.config/index/settings.toml"

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

local function decodeSettings(text)
  local links, engines, snippets = {}, {}, {}
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
    elseif currentTable == "snippets" then
      if fields.title and fields.text then
        table.insert(snippets, { title = fields.title, text = fields.text, trigger = fields.trigger })
      else
        logger.wf("Skipping [[snippets]] entry missing title or text")
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
  return links, engines, snippets
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

-- Index's ranking: a greedy subsequence match rewarding consecutive runs,
-- multiplied by (1 + frecency). An exact trigger match always ranks first.

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

local function rank(query, title, trigger, frecency)
  if query == "" then return frecency end
  if trigger and trigger:lower() == query:lower() then return math.huge end
  local score = fuzzyScore(query, title)
  return score and score * (1 + frecency)
end

function M.recordUse(settingsKey, key)
  local usage = hs.settings.get(settingsKey) or {}
  local entry = usage[key] or { count = 0, lastUsed = 0 }
  entry.count = entry.count + 1
  entry.lastUsed = os.time()
  usage[key] = entry
  hs.settings.set(settingsKey, usage)
end

local cache = { modified = nil, links = {}, engines = {}, snippets = {} }

function M.loadSettings()
  local modified = hs.fs.attributes(settingsPath, "modification")
  if not modified then
    logger.wf("Index settings not found at %s", settingsPath)
    return {}, {}, {}
  end
  if modified ~= cache.modified then
    local file = io.open(settingsPath, "r")
    if file then
      cache.links, cache.engines, cache.snippets = decodeSettings(file:read("a"))
      cache.modified = modified
      file:close()
    end
  end
  return cache.links, cache.engines, cache.snippets
end

M.trim = trim
M.percentEncode = percentEncode
M.expandPlaceholders = expandPlaceholders
M.rank = rank
M.frecencyScore = frecencyScore

return M
