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
