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
-- See: https://github.com/vscode-neovim/vscode-neovim/issues/2117#issuecomment-2907635547
-- 1. Redraw on CursorHold (idle for some time)
local redraw_fix = vim.api.nvim_create_augroup("VSCodeRedrawFix", { clear = true })
vim.api.nvim_create_autocmd("CursorHold", {
  group = redraw_fix,
  callback = function()
    vim.cmd("silent! mode") -- triggers a lightweight redraw
  end,
})

-- 2. Redraw immediately after text changes (e.g., visual delete)
local redraw_group = vim.api.nvim_create_augroup("RedrawOnDelete", { clear = true })
vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
  group = redraw_group,
  callback = function()
    if vim.fn.mode() == "n" then
      vim.cmd("silent! mode") -- refresh UI after delete/insert
    end
  end,
})
