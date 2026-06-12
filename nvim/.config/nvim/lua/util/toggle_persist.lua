local M = {}

local workspace_path = vim.fn.getcwd()
local unique_id = vim.fn.fnamemodify(workspace_path, ":t") .. "_" .. vim.fn.sha256(workspace_path):sub(1, 8)
local store_dir = vim.fn.stdpath("data") .. "/snacks-toggles"
local store_file = store_dir .. "/" .. unique_id .. ".json"

local cache ---@type table<string, boolean>|nil

local function load()
  if cache then
    return cache
  end
  cache = {}
  local f = io.open(store_file, "r")
  if not f then
    return cache
  end
  local content = f:read("*a")
  f:close()
  local ok, decoded = pcall(vim.json.decode, content)
  if ok and type(decoded) == "table" then
    cache = decoded
  end
  return cache
end

local function save()
  vim.fn.mkdir(store_dir, "p")
  local f = io.open(store_file, "w")
  if not f then
    return
  end
  f:write(vim.json.encode(cache or {}))
  f:close()
end

---Wrap a snacks toggle so its state persists per-workspace.
---@param toggle snacks.toggle.Class
---@return snacks.toggle.Class
function M.wrap(toggle)
  local id = toggle.opts.id
  local store = load()

  local original_set = toggle.opts.set
  toggle.opts.set = function(state)
    original_set(state)
    cache[id] = state
    save()
  end

  if store[id] ~= nil then
    -- Defer so the toggle's underlying subsystem (LSP, diagnostics, options)
    -- is fully initialised before we apply restored state.
    vim.schedule(function()
      local ok, current = pcall(toggle.opts.get)
      if ok and current ~= store[id] then
        toggle:set(store[id])
      end
    end)
  end

  return toggle
end

return M
