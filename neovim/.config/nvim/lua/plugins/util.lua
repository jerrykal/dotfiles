return {
  -- Library used by other plugins
  { "nvim-lua/plenary.nvim", lazy = false },

  -- Session management
  {
    "rmagatti/auto-session",
    event = "VimEnter",
    opts = {
      log_level = "error",
    },
  },

  { "tpope/vim-repeat", event = "VeryLazy" },
}
