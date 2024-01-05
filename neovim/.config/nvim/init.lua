local config_root = "config"
if vim.g.vscode then
  config_root = "config.vscode"
end

-- General configurations
require(config_root .. ".options")

-- Load after plugins
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = function()
    -- Key mappings
    require(config_root .. ".keymaps")

    -- Autocommands
    require(config_root .. ".autocmds")
  end,
})

-- Plugins
require("config.lazy")
