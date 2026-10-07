-- Emoji picker, mimicking Tinycast's: a searchable list of every emoji, with
-- the most frecently used ones first. Return pastes the emoji into the
-- previously focused app; cmd+Return copies it instead.
--
-- emoji.json is generated from Unicode's emoji-test.txt (order and
-- categories), CLDR annotations and GitHub's gemoji (search keywords), and
-- macOS's CoreEmoji AppleName.strings (names, and filtering out emoji this
-- macOS version can't render).

local webchooser = require("webchooser")

local M = {}

local usageSettingsKey = "emojiPickerUsage"

local emoji = hs.json.read(hs.configdir .. "/emoji.json")
local byEmoji = {}

local function words(s, pattern)
  local out = {}
  for w in s:gmatch(pattern) do table.insert(out, w) end
  return out
end

for i, e in ipairs(emoji) do
  e.index = i
  e.lowerName = e.n:lower()
  e.nameWords = words(e.lowerName, "[^%s%p]+")
  e.keywordWords = {}
  for _, k in ipairs(e.k) do
    for _, w in ipairs(words(k, "[^%s_:%-]+")) do table.insert(e.keywordWords, w) end
  end
  e.choice = {
    text = e.e .. "  " .. e.n:sub(1, 1):upper() .. e.n:sub(2),
    subText = #e.k > 0 and (e.c .. " · " .. table.concat(e.k, ", ")) or e.c,
    emoji = e.e,
  }
  byEmoji[e.e] = e
end

local function frecencyScore(entry)
  local hoursSinceUse = (os.time() - entry.lastUsed) / 3600
  local recency = 1 / (1 + hoursSinceUse / 24)
  return entry.count * 0.6 + recency * 0.4
end

local function frecencyScores()
  local scores = {}
  for e, entry in pairs(hs.settings.get(usageSettingsKey) or {}) do
    scores[e] = frecencyScore(entry)
  end
  return scores
end

local function recordUse(e)
  local usage = hs.settings.get(usageSettingsKey) or {}
  local entry = usage[e] or { count = 0, lastUsed = 0 }
  entry.count = entry.count + 1
  entry.lastUsed = os.time()
  usage[e] = entry
  hs.settings.set(usageSettingsKey, usage)
end

local function contains(list, word)
  for _, w in ipairs(list) do
    if w == word then return true end
  end
  return false
end

local function anyStartsWith(list, prefix)
  for _, w in ipairs(list) do
    if w:sub(1, #prefix) == prefix then return true end
  end
  return false
end

local function termScore(e, term)
  if contains(e.nameWords, term) then return 4 end
  if anyStartsWith(e.nameWords, term) then return 3 end
  if contains(e.keywordWords, term) then return 2 end
  if anyStartsWith(e.keywordWords, term) then return 1 end
  return 0
end

local function score(e, query, terms)
  local total = 0
  for _, term in ipairs(terms) do
    local s = termScore(e, term)
    if s == 0 then return 0 end
    total = total + s
  end
  if e.lowerName == query then
    total = total + 10
  elseif e.nameWords[#e.nameWords] == terms[#terms] then
    total = total + 2
  elseif e.lowerName:sub(1, #query) == query then
    total = total + 1
  end
  return total
end

local frecency = {}

local function search(rawQuery)
  local query = rawQuery:lower():match("^%s*(.-)%s*$"):gsub("^:", ""):gsub(":$", "")
  local results = {}
  if query == "" then
    for e in pairs(frecency) do
      if byEmoji[e] then table.insert(results, byEmoji[e]) end
    end
    table.sort(results, function(a, b) return frecency[a.e] > frecency[b.e] end)
    for _, e in ipairs(emoji) do
      if not frecency[e.e] then table.insert(results, e) end
    end
    return results
  end

  local terms = words(query, "%S+")
  local ranks = {}
  for _, e in ipairs(emoji) do
    local s = score(e, query, terms)
    if s > 0 then
      ranks[e] = s * (1 + (frecency[e.e] or 0))
      table.insert(results, e)
    end
  end
  table.sort(results, function(a, b)
    if ranks[a] ~= ranks[b] then return ranks[a] > ranks[b] end
    if #a.n ~= #b.n then return #a.n < #b.n end
    return a.index < b.index
  end)
  return results
end

local function insert(e, copyOnly)
  recordUse(e)
  if copyOnly then
    hs.pasteboard.setContents(e)
    hs.alert.show("Copied " .. e)
    return
  end
  local saved = hs.pasteboard.readAllData()
  hs.pasteboard.setContents(e)
  hs.timer.doAfter(0.1, function()
    hs.eventtap.keyStroke({ "cmd" }, "v", 0)
    hs.timer.doAfter(0.3, function() hs.pasteboard.writeAllData(saved) end)
  end)
end

local chooser = webchooser.new(function(choice)
  if not choice then return end
  insert(choice.emoji, hs.eventtap.checkKeyboardModifiers().cmd)
end)
chooser:placeholderText("Search emoji…")
chooser:queryChangedCallback(function(query)
  local choices = {}
  for i, e in ipairs(search(query)) do choices[i] = e.choice end
  chooser:choices(choices)
end)

function M.show()
  frecency = frecencyScores()
  chooser:query("")
  chooser:show()
end

return M
