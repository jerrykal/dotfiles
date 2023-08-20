return {
  -- Library used by other plugins
  { "nvim-lua/plenary.nvim", lazy = false },

  -- Session management
  {
    "rmagatti/auto-session",
    event = "VimEnter",
    opts = {
      log_level = "error",
      pre_save_cmds = {
        "tabdo Neotree close",
        "tabdo AerialCloseAll",
      },
    },
    config = function(_, opts)
      -- Close lazy and re-open it after restoring session
      if vim.o.filetype == "lazy" then
        vim.cmd.close()
        opts.post_restore_cmds = { require("lazy").show }
      end
      require("auto-session").setup(opts)
    end,
  },

  -- Tmux integration
  {
    "aserowy/tmux.nvim",
    event = "VimEnter",
    opts = {
      copy_sync = { enable = false },
    },
  },

  { "tpope/vim-repeat", event = "VeryLazy" },
}
