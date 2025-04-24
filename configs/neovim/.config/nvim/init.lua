local config_root = "config"
if vim.g.vscode then
  config_root = "config.vscode"
end

-- General configurations
pcall(require, config_root .. ".options")

-- Load after plugins
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = function()
    -- Key mappings
    pcall(require, config_root .. ".keymaps")

    -- Autocommands
    pcall(require, config_root .. ".autocmds")
  end,
})

require("config.lazy")
