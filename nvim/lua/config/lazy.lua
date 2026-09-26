-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Add support for the LazyFile event
-- https://github.com/LazyVim/LazyVim/discussions/1583#discussioncomment-7187450
local Event = require("lazy.core.handler.event")
Event.mappings.LazyFile = { id = "LazyFile", event = { "BufReadPost", "BufNewFile", "BufWritePre" } }
Event.mappings["User LazyFile"] = Event.mappings.LazyFile

-- Plugins that still load inside VSCode
local vscode_plugins = {
  "dial.nvim",
  "flash.nvim",
  "lazy.nvim",
  "mini.ai",
  "mini.surround",
  "nvim-treesitter",
  "nvim-treesitter-textobjects",
  "yanky.nvim",
}

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    { import = "plugins" },
    { import = "plugins.lang" },
  },
  defaults = {
    cond = vim.g.vscode and function(plugin)
      return vim.tbl_contains(vscode_plugins, plugin.name)
    end or nil,
  },
  change_detection = {
    enabled = not vim.g.vscode,
  },
  install = {
    colorscheme = { "rose-pine" },
  },
  rocks = {
    enabled = false,
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
