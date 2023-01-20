-- Python specific config
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    vim.opt_local.colorcolumn = { 89 }
  end
})

-- Lua specific config
vim.api.nvim_create_autocmd("FileType", {
  pattern = "lua",
  callback = function()
    vim.opt_local.colorcolumn = { 121 }
  end
})

-- C/C++ specific config
vim.api.nvim_create_autocmd("FileType", {
  pattern = {"c", "cpp"},
  callback = function()
    vim.opt_local.colorcolumn = { 81 }
  end
})
