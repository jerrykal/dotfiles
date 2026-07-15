return {
  -- Live markdown rendering with proper formatting in the editor
  {
    "OXY2DEV/markview.nvim",
    lazy = false, -- markview.nvim lazy loads itself
    enabled = vim.env.GHOSTTY_QUICK_TERMINAL == nil, -- plain text in the quick-terminal scratchpad
    opts = {
      preview = {
        hybrid_modes = { "n" },
      },
    },
  },

  {
    "dkarter/bullets.vim",
    ft = "markdown",
  },
}
