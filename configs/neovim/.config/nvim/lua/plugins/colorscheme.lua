return {
  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = false,
    priority = 1000,
    opts = {
      highlight_groups = {
        WinBar = { bg = "base" },
        WinBarNC = { bg = "base" },

        -- folke/snacks.nvim
        SnacksIndentScope = { fg = "muted" },
        SnacksIndent = { fg = "highlight_med" },
        SnacksIndentChunk = { fg = "highlight_med" },

        -- SmiteshP/nvim-navic
        NavicText = { fg = "muted" },
        NavicSeparator = { fg = "muted" },
      },
    },
    config = function(_, opts)
      require("rose-pine").setup(opts)
      vim.cmd([[colorscheme rose-pine]])
    end,
  },
}
