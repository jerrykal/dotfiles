if not vim.g.vscode then
  return {}
end

local enabled = {
  "dial.nvim",
  "flash.nvim",
  "lazy.nvim",
  "mini.ai",
  "mini.surround",
  "nvim-treesitter",
  "nvim-treesitter-textobjects",
  "tabout.nvim",
  "treesj",
  "vim-repeat",
  "yanky.nvim",
}

local Config = require("lazy.core.config")
Config.options.checker.enabled = false
Config.options.change_detection.enabled = false
Config.options.defaults.cond = function(plugin)
  return vim.tbl_contains(enabled, plugin.name)
end

return {}
