return {
  -- Live markdown rendering with proper formatting in the editor
  {
    "OXY2DEV/markview.nvim",
    lazy = false, -- markview.nvim lazy loads itself
    opts = {},
  },

  {
    "dkarter/bullets.vim",
    ft = "markdown",
  },
}
