-- Snippet picker: fuzzy-find Index's snippets by title or trigger. Return
-- pastes the snippet into the previously focused app; cmd+Return copies it
-- instead.

local index = require("index")
local webchooser = require("webchooser")

local M = {}

local usageSettingsKey = "snippetPickerUsage"

local snippets = {}
local results = {}

local function search(query)
  local usage = hs.settings.get(usageSettingsKey) or {}
  local scored = {}
  for _, snippet in ipairs(snippets) do
    local score = index.fuzzyScore(query, snippet.title)
    local triggerScore = snippet.trigger and index.fuzzyScore(query, snippet.trigger)
    if triggerScore and (not score or triggerScore > score) then score = triggerScore end
    if score then
      local frecency = index.frecencyScore(usage[snippet.title])
      table.insert(scored, { snippet = snippet, rank = query == "" and frecency or score * (1 + frecency) })
    end
  end
  table.sort(scored, function(a, b)
    if a.rank == b.rank then return a.snippet.title:lower() < b.snippet.title:lower() end
    return a.rank > b.rank
  end)
  local out = {}
  for i, s in ipairs(scored) do out[i] = s.snippet end
  return out
end

local function subText(snippet)
  local preview = index.trim(snippet.text):gsub("%s*\n%s*", " ⏎ ")
  if snippet.trigger then return snippet.trigger .. " · " .. preview end
  return preview
end

local function insert(snippet, copyOnly)
  index.recordUse(usageSettingsKey, snippet.title)
  local text = index.expandPlaceholders(snippet.text)
  if copyOnly then
    hs.pasteboard.setContents(text)
    hs.alert.show("Copied " .. snippet.title)
    return
  end
  local saved = hs.pasteboard.readAllData()
  hs.pasteboard.setContents(text)
  hs.timer.doAfter(0.1, function()
    hs.eventtap.keyStroke({ "cmd" }, "v", 0)
    hs.timer.doAfter(0.3, function() hs.pasteboard.writeAllData(saved) end)
  end)
end

local chooser

chooser = webchooser.new(function(choice)
  if not choice then return end
  local snippet = results[choice.id]
  if snippet then insert(snippet, hs.eventtap.checkKeyboardModifiers().cmd) end
end)
chooser:placeholderText("Search snippets…")
chooser:queryChangedCallback(function(query)
  results = search(index.trim(query))
  local choices = {}
  for i, snippet in ipairs(results) do
    choices[i] = { text = snippet.title, subText = subText(snippet), id = i }
  end
  chooser:choices(choices)
end)

function M.show()
  local _, _, loaded = index.loadSettings()
  snippets = loaded
  chooser:query("")
  chooser:show()
end

return M
