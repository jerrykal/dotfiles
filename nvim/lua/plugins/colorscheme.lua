return {
  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = false,
    priority = 10000,
    opts = {
      extend_background_behind_borders = false,
      styles = {
        -- The default uses too much italic :(
        italic = false,
      },
      groups = {
        border = "highlight_high",
        panel = "base",
      },
      highlight_groups = {
        DiffDelete = { fg = "highlight_med", bg = "base" },
        StatusLine = { bg = "surface" },
        StatusLineNC = { bg = "surface" },
        WinBar = { bg = "base" },
        WinBarNC = { bg = "base" },

        -- This is all the italics I need :)
        Comment = { italic = true },
        ["@markup.italic"] = { italic = true },
        htmlItalic = { italic = true },

        -- nvim-treesitter/nvim-treesitter-context
        TreesitterContext = { bg = "base" },
        TreesitterContextLineNumber = { bg = "base" },

        -- folke/snacks.nvim
        SnacksIndentScope = { fg = "muted" },
        SnacksIndent = { fg = "highlight_med" },
        SnacksIndentChunk = { fg = "highlight_med" },
        SnacksDiffDelete = { bg = "love", blend = 20 },
        SnacksDiffDeleteLineNr = { link = "SnacksDiffDelete" },

        -- SmiteshP/nvim-navic
        NavicText = { fg = "muted" },
        NavicSeparator = { fg = "muted" },

        -- lewis6991/gitsigns
        GitSignsAddInline = { bg = "foam", blend = 40 },
        GitSignsDeleteInline = { bg = "love", blend = 40 },
        GitSignsChangeInline = { bg = "gold", blend = 40 },
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
