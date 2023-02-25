-- Show git branch name and status
local function git_status()
  if vim.g.loaded_fugitive == nil or vim.fn.FugitiveIsGitDir() == 0 then
    return ""
  end
  return string.format("  שׂ %s %s ", vim.fn.FugitiveHead(), vim.b.gitsigns_status)
end

-- Show lsp diagnostics results on current buffer
local function lsp_diagnostic()
  local count = {}
  local levels = {
    errors = "Error",
    warnings = "Warn",
  }

  for k, level in pairs(levels) do
    count[k] = vim.tbl_count(vim.diagnostic.get(0, { severity = level }))
  end

  return string.format(" %d  %d", count["errors"], count["warnings"])
end

-- Show file encoding
local function encoding()
  if vim.bo.fileencoding == "" then
    return vim.o.encoding:upper()
  else
    return vim.bo.fileencoding:upper()
  end
end

-- Show file type
local function filetype()
  if vim.bo.filetype == "" then
    return ""
  end
  local icon = require("nvim-web-devicons").get_icon_by_filetype(vim.bo.filetype)
  return string.format(
    " %s %s  ",
    icon and icon or "",
    vim.bo.filetype:gsub("(%l)(%w*)", function(a, b)
      return string.upper(a) .. b
    end)
  )
end

-- Show indentation setup
local function indentation()
  if vim.bo.expandtab then
    return string.format("Space: %d", vim.bo.tabstop)
  else
    return string.format("Tab: %d", vim.bo.tabstop)
  end
end

-- etc
local lineinfo = "Ln %l, Col %c%4p%%"
local fileformat = vim.bo.fileformat:upper()

local M = {}

M.setup = function()
  if vim.bo.buftype == "Trouble"
      or vim.bo.buftype == "mason"
      or vim.bo.buftype == "prompt"
      or vim.bo.buftype == "terminal"
      or vim.bo.filetype == "help"
      or vim.bo.filetype == "lazy"
      or vim.bo.filetype == "neo-tree"
  then
    return string.format("  %s %%=%s  ", lsp_diagnostic(), lineinfo)
  else
    return string.format(
      "%s  %s%%=%s   %s   %s   %s  %s",
      git_status(),
      lsp_diagnostic(),
      lineinfo,
      indentation(),
      encoding(),
      fileformat,
      filetype()
    )
  end
end

return M
