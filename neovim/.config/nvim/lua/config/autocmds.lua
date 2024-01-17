-- Python specific config
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    vim.opt_local.colorcolumn = { 89 }
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
  end,
})

-- Lua specific config
vim.api.nvim_create_autocmd("FileType", {
  pattern = "lua",
  callback = function()
    vim.opt_local.colorcolumn = { 121 }
  end,
})

-- C/C++ specific config
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c", "cpp" },
  callback = function()
    vim.opt_local.colorcolumn = { 81 }
  end,
})

-- Shell script specific config
vim.api.nvim_create_autocmd("FileType", {
  pattern = "sh",
  callback = function()
    vim.opt_local.colorcolumn = { 81 }
  end,
})

-- Disable auto comment when press enter
vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    vim.opt_local.formatoptions:remove({ "t", "c", "r", "o" })
  end,
})

-- Change filetype for .json files to jsonc
vim.api.nvim_create_autocmd({"BufNewFile", "BufRead"}, {
  pattern = "*.json",
  callback = function()
    vim.bo.filetype = "jsonc"
  end,
})
