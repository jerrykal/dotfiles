return {
  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = false,
    priority = 10000,
    opts = {
      highlight_groups = {
        WinBar = { bg = "base" },
        WinBarNC = { bg = "base" },
        DiffDelete = { fg = "highlight_med", bg = "base" },

        -- nvim-treesitter/nvim-treesitter-context
        TreesitterContext = { bg = "base" },
        TreesitterContextLineNumber = { bg = "base" },

        -- folke/snacks.nvim
        SnacksIndentScope = { fg = "muted" },
        SnacksIndent = { fg = "highlight_med" },
        SnacksIndentChunk = { fg = "highlight_med" },

        -- SmiteshP/nvim-navic
        NavicText = { fg = "muted" },
        NavicSeparator = { fg = "muted" },

        -- lewis6991/gitsigns
        GitSignsDeletePreview = { bg = "love", blend = 20 },
        GitSignsDeleteVirtLn = { link = "GitSignsDeletePreview" },
      },
    },
    config = function(_, opts)
      require("rose-pine").setup(opts)
      vim.cmd([[colorscheme rose-pine]])
    end,
  },
}
