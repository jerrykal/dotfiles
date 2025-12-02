local config_root = "config"
if vim.g.vscode then
  config_root = "config.vscode"
end

pcall(require, config_root .. ".options")
vim.api.nvim_create_autocmd("User", {
  group = vim.api.nvim_create_augroup("keymaps_and_autocmds", { clear = true }),
  pattern = "VeryLazy",
  callback = function()
    -- Key mappings
    pcall(require, config_root .. ".keymaps")

    -- Autocommands
    pcall(require, config_root .. ".autocmds")
  end,
})
require("config.lazy")
