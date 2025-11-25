local M = {}

local function git_status()
  local git_info = vim.b.gitsigns_status_dict
  if git_info then
    local added = git_info.added and git_info.added ~= 0 and " +" .. git_info.added or ""
    local changed = git_info.added and git_info.changed ~= 0 and " ~" .. git_info.changed or ""
    local removed = git_info.added and git_info.removed ~= 0 and " -" .. git_info.removed or ""

    return "[ " .. git_info.head .. added .. changed .. removed .. "]"
  end

  return ""
end

local function lsp_diagnostics()
  local error_count = vim.tbl_count(vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR }))
  local warn_count = vim.tbl_count(vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN }))

  local errors = error_count ~= 0 and " " .. error_count or ""
  local warns = warn_count ~= 0 and "  " .. warn_count or ""

  return errors .. warns
end

function M.statusline()
  return table.concat({
    " ",
    git_status(),
    " %f ",
    "%=",
    lsp_diagnostics(),
    " %y [%P %l:%c] ",
  })
end

return M
