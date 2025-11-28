local config_root = "configs"
if vim.g.vscode then
  config_root = "configs.vscode"
end

-- General configurations
pcall(require, config_root .. ".options")

-- Load after plugins
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

require("configs.lazy")
