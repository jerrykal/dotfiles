local function augroup(name)
  return vim.api.nvim_create_augroup("lazyvim_" .. name, { clear = true })
end

-- Refresh statusline on event
vim.api.nvim_create_autocmd("DiagnosticChanged", {
  group = augroup("refresh_statusline"),
  callback = function()
    vim.cmd("redrawstatus")
  end,
})
