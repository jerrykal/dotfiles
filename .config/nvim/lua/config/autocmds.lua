local autocmd = vim.api.nvim_create_autocmd
local function augroup(name)
  return vim.api.nvim_create_augroup(name, { clear = true })
end

-- Trim trailing whitespace
autocmd("BufWritePre", {
  group = augroup("trim_trailing_whitespace"),
  pattern = "*",
  command = "%s/\\s\\+$//e",
})

-- Refresh statusline on event
autocmd("DiagnosticChanged", {
  group = augroup("refresh_statusline"),
  pattern = "*",
  callback = function()
    vim.cmd("redrawstatus")
  end,
})
