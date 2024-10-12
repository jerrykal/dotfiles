-- Disable auto comment when press enter
vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    vim.opt_local.formatoptions:remove({ "t", "c", "r", "o" })
  end,
})

-- Change filetype for .json files to jsonc
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  pattern = "*.json",
  callback = function()
    vim.bo.filetype = "jsonc"
  end,
})

-- Automatically redraw to fix phantom cursor issue
-- See: https://github.com/vscode-neovim/vscode-neovim/issues/2117
vim.api.nvim_create_autocmd("CursorHold", {
  pattern = "*",
  callback = function ()
    vim.cmd("silent! mode")
  end
})