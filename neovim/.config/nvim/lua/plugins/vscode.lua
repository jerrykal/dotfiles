if not vim.g.vscode then
  return {}
end

-- Enable these plugins in VSCode
local enabled = {
  "Comment.nvim",
  "flash.nvim",
  "lazy.nvim",
  "nvim-surround",
  "nvim-treesitter",
  "nvim-treesitter-textobjects",
  "nvim-various-textobjs",
  "vim-repeat",
}

local Config = require("lazy.core.config")
Config.options.checker.enabled = false
Config.options.change_detection.enabled = false
Config.options.defaults.cond = function(plugin)
  return vim.tbl_contains(enabled, plugin.name)
end

-- Overrides default plugin configurations
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { highlight = { enable = false } },
  },
}
