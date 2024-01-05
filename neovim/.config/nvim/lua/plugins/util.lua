return {
  -- Library used by other plugins
  { "nvim-lua/plenary.nvim", lazy = false },

  -- Session management
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    -- stylua: ignore
    keys = {
      { "<leader>qs", function() require("persistence").load() end, desc = "Restore Session" },
      { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore Last Session" },
      { "<leader>qd", function() require("persistence").stop() end, desc = "Don't Save Current Session" },
    },
    opts = { options = vim.opt.sessionoptions:get() },
  },

  -- Tmux integration
  {
    "aserowy/tmux.nvim",
    event = "VimEnter",
    opts = {
      copy_sync = { sync_unnamed = false },
    },
  },

  { "tpope/vim-repeat", event = "VeryLazy" },
}
