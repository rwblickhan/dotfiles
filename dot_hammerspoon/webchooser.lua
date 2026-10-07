-- A drop-in subset of hs.chooser rendered in an hs.webview, so it can have
-- rounded corners and a native-looking translucent panel.
--
-- Supported: new(callback), choices(table), query(string), placeholderText(string),
-- queryChangedCallback(fn), show(), hide(), cancel(), isVisible().
-- Choices use hs.chooser's shape: { text, subText, image, ... }. Without a
-- queryChangedCallback, choices are filtered by the words in the query.

local M = {}
M.__index = M

local width = 720
local rowHeight = 48
local inputHeight = 56
local visibleRows = 9
local margin = 24
local cornerRadius = 14
local iconSize = 64

local html = [[
<!doctype html>
<html>
<head>
<meta charset="utf-8">
<style>
  :root {
    color-scheme: light dark;
    --bg: rgba(246, 246, 246, 0.94);
    --fg: #1d1d1f;
    --sub: rgba(60, 60, 67, 0.6);
    --sep: rgba(0, 0, 0, 0.1);
    --sel: rgba(0, 0, 0, 0.07);
    --border: rgba(0, 0, 0, 0.12);
  }
  @media (prefers-color-scheme: dark) {
    :root {
      --bg: rgba(36, 36, 38, 0.94);
      --fg: #f5f5f7;
      --sub: rgba(235, 235, 245, 0.55);
      --sep: rgba(255, 255, 255, 0.1);
      --sel: rgba(255, 255, 255, 0.1);
      --border: rgba(255, 255, 255, 0.14);
    }
  }
  html, body {
    margin: 0;
    background: transparent;
    font: 14px -apple-system, BlinkMacSystemFont, sans-serif;
    color: var(--fg);
    overflow: hidden;
    user-select: none;
    -webkit-user-select: none;
    cursor: default;
  }
  #panel {
    margin: MARGINpx;
    height: calc(100vh - 2 * MARGINpx);
    display: flex;
    flex-direction: column;
    background: var(--bg);
    border-radius: RADIUSpx;
    box-shadow: 0 0 0 0.5px var(--border), 0 12px 32px rgba(0, 0, 0, 0.3);
    overflow: hidden;
  }
  #query {
    flex: none;
    height: INPUTpx;
    padding: 0 18px;
    border: none;
    border-bottom: 1px solid var(--sep);
    outline: none;
    background: transparent;
    color: var(--fg);
    font: 20px -apple-system, BlinkMacSystemFont, sans-serif;
  }
  #query::placeholder { color: var(--sub); }
  #list { flex: 1; overflow-y: auto; padding: 6px; }
  #list::-webkit-scrollbar { display: none; }
  .row {
    display: flex;
    align-items: center;
    height: ROWpx;
    padding: 0 10px;
    border-radius: 8px;
    box-sizing: border-box;
  }
  .row.selected { background: var(--sel); }
  .row img { width: 32px; height: 32px; margin-right: 12px; flex: none; }
  .text { min-width: 0; }
  .title, .sub { white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
  .sub { font-size: 12px; color: var(--sub); margin-top: 1px; }
</style>
</head>
<body>
<div id="panel">
  <input id="query" autocomplete="off" spellcheck="false">
  <div id="list"></div>
</div>
<script>
  const input = document.getElementById("query");
  const list = document.getElementById("list");
  const icons = {};
  let count = 0;
  let selected = 0;

  function post(message) { webkit.messageHandlers.NAME.postMessage(message); }

  function select(index) {
    if (count === 0) return;
    selected = Math.max(0, Math.min(count - 1, index));
    list.querySelectorAll(".row.selected").forEach(r => r.classList.remove("selected"));
    const row = list.children[selected];
    row.classList.add("selected");
    row.scrollIntoView({ block: "nearest" });
  }

  window.setChoices = function (choices, newIcons) {
    Object.assign(icons, newIcons);
    list.replaceChildren(...choices.map((choice, i) => {
      const row = document.createElement("div");
      row.className = "row";
      if (choice.icon) {
        const icon = document.createElement("img");
        icon.src = icons[choice.icon];
        row.append(icon);
      }
      const text = document.createElement("div");
      text.className = "text";
      const title = document.createElement("div");
      title.className = "title";
      title.textContent = choice.text;
      text.append(title);
      if (choice.subText) {
        const sub = document.createElement("div");
        sub.className = "sub";
        sub.textContent = choice.subText;
        text.append(sub);
      }
      row.append(text);
      row.addEventListener("mousemove", () => { if (selected !== i) select(i); });
      row.addEventListener("click", () => post({ type: "select", index: i + 1 }));
      return row;
    }));
    count = choices.length;
    list.scrollTop = 0;
    select(0);
  };

  window.setQuery = function (query, placeholder) {
    input.value = query;
    input.placeholder = placeholder;
    input.focus();
  };

  input.addEventListener("input", () => post({ type: "query", query: input.value }));
  document.addEventListener("keydown", e => {
    const ctrl = e.ctrlKey && !e.metaKey && !e.altKey;
    if (e.key === "ArrowDown" || (ctrl && e.key === "n")) select(selected + 1);
    else if (e.key === "ArrowUp" || (ctrl && e.key === "p")) select(selected - 1);
    else if (e.key === "PageDown") select(selected + VISIBLE);
    else if (e.key === "PageUp") select(selected - VISIBLE);
    else if (e.key === "Enter") { if (count > 0) post({ type: "select", index: selected + 1 }); }
    else if (e.key === "Escape") post({ type: "cancel" });
    else return;
    e.preventDefault();
  });
  document.addEventListener("mousedown", e => {
    if (!document.getElementById("panel").contains(e.target)) post({ type: "cancel" });
  });
</script>
</body>
</html>
]]

local icons = setmetatable({}, { __mode = "k" })
local nextIconID = 0

local function iconFor(image)
  if not image then return nil end
  if icons[image] == nil then
    local resized = image:setSize({ w = iconSize, h = iconSize }, true)
    local url = resized and resized:encodeAsURLString(false, "PNG")
    if url then
      nextIconID = nextIconID + 1
      icons[image] = { id = tostring(nextIconID), url = url }
    else
      icons[image] = false
    end
  end
  return icons[image] or nil
end

local nextID = 0

function M.new(callback)
  nextID = nextID + 1
  local self = setmetatable({
    callback = callback,
    allChoices = {},
    currentChoices = {},
    currentQuery = "",
    placeholder = "",
    sentIcons = {},
    visible = false,
  }, M)

  local name = "webchooser" .. nextID
  local page = html
    :gsub("MARGIN", tostring(margin))
    :gsub("RADIUS", tostring(cornerRadius))
    :gsub("INPUT", tostring(inputHeight))
    :gsub("ROW", tostring(rowHeight))
    :gsub("VISIBLE", tostring(visibleRows))
    :gsub("NAME", name)

  local content = hs.webview.usercontent.new(name)
  content:setCallback(function(message) self:handleMessage(message.body) end)

  self.webview = hs.webview.new({ x = 0, y = 0, w = 1, h = 1 }, {}, content)
    :windowStyle({ "borderless" })
    :transparent(true)
    :shadow(false)
    :allowTextEntry(true)
    :level(hs.drawing.windowLevels.modalPanel)
    :behaviorAsLabels({ "canJoinAllSpaces", "transient" })
    :windowCallback(function(action, _, hasFocus)
      if action == "focusChange" and not hasFocus and self.visible then self:cancel() end
    end)
    :html(page)

  return self
end

function M:eval(fn, ...)
  local args = {}
  for i, arg in ipairs({ ... }) do args[i] = hs.json.encode({ arg }):sub(2, -2) end
  self.webview:evaluateJavaScript(string.format("%s(%s)", fn, table.concat(args, ",")))
end

local function matches(text, words)
  text = text:lower()
  for _, word in ipairs(words) do
    if not text:find(word, 1, true) then return false end
  end
  return true
end

function M:queryChanged()
  if self.queryCallback then
    self.queryCallback(self.currentQuery)
    return
  end
  local words = {}
  for word in self.currentQuery:lower():gmatch("%S+") do table.insert(words, word) end
  local filtered = {}
  for _, choice in ipairs(self.allChoices) do
    if matches(choice.text or "", words) then table.insert(filtered, choice) end
  end
  self:render(filtered)
end

function M:handleMessage(message)
  if message.type == "query" then
    self.currentQuery = message.query
    self:queryChanged()
  elseif message.type == "select" then
    local choice = self.currentChoices[message.index]
    self:hide()
    self:restoreFocus()
    if choice then self.callback(choice) end
  elseif message.type == "cancel" then
    self:cancel()
  end
end

function M:choices(choices)
  self.allChoices = choices
  if self.queryCallback then
    self:render(choices)
  else
    self:queryChanged()
  end
  return self
end

function M:render(choices)
  self.currentChoices = choices
  local rendered, newIcons = {}, {}
  for i, choice in ipairs(choices) do
    local icon = iconFor(choice.image)
    if icon and not self.sentIcons[icon.id] then
      self.sentIcons[icon.id] = true
      newIcons[icon.id] = icon.url
    end
    rendered[i] = { text = choice.text, subText = choice.subText, icon = icon and icon.id }
  end
  self:eval("setChoices", rendered, newIcons)
end

function M:query(query)
  if query == nil then return self.currentQuery end
  self.currentQuery = query
  self:eval("setQuery", query, self.placeholder)
  self:queryChanged()
  return self
end

function M:placeholderText(text)
  self.placeholder = text
  return self
end

function M:queryChangedCallback(fn)
  self.queryCallback = fn
  return self
end

function M:isVisible()
  return self.visible
end

function M:show()
  local previousWindow = hs.window.focusedWindow()
  local frame = (previousWindow and previousWindow:screen() or hs.screen.mainScreen()):frame()
  local w = width + 2 * margin
  local h = inputHeight + 12 + rowHeight * visibleRows + 2 * margin
  self.webview:frame({
    x = frame.x + (frame.w - w) / 2,
    y = frame.y + frame.h * 0.18 - margin,
    w = w,
    h = h,
  })
  local previousApp = hs.application.frontmostApplication()
  if previousApp and previousApp:bundleID() ~= hs.processInfo.bundleID then
    self.previousApp = previousApp
    self.previousWindow = previousWindow
  end
  self.visible = true
  hs.focus()
  self.webview:show()
  self:eval("setQuery", self.currentQuery, self.placeholder)
  return self
end

function M:hide()
  if not self.visible then return self end
  self.visible = false
  self.webview:hide()
  return self
end

function M:cancel()
  if not self.visible then return self end
  self:hide()
  self:restoreFocus()
  self.callback(nil)
  return self
end

function M:restoreFocus()
  if self.previousWindow and self.previousWindow:isVisible() then
    self.previousWindow:focus()
  elseif self.previousApp then
    self.previousApp:activate()
  end
end

return M
