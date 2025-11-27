local function augroup(name)
  return vim.api.nvim_create_augroup(name, { clear = true })
end

-- Refresh statusline on event
vim.api.nvim_create_autocmd("DiagnosticChanged", {
  group = augroup("refresh_statusline"),
  callback = function()
    vim.cmd("redrawstatus")
  end,
})

-- Disable auto comment when press enter
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("custom_formatoptions"),
  pattern = "*",
  callback = function()
    vim.opt_local.formatoptions:remove({ "t", "c", "r", "o" })
  end,
})
