return {
  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = false,
    priority = 1000,
    opts = {
      styles = {
        -- The default uses too much italic :(
        italic = false,
      },
      groups = {
        border = "highlight_high",
      },
      highlight_groups = {
        DiffDelete = { fg = "highlight_med", bg = "base" },
        WinBar = { bg = "base" },
        WinBarNC = { bg = "base" },

        -- This is all the italics I need :)
        Comment = { italic = true },
        ["@markup.italic"] = { italic = true },
        htmlItalic = { italic = true },

        -- nvim-treesitter/nvim-treesitter-context
        TreesitterContextLineNumber = { link = "LineNr" },

        -- folke/snacks.nvim
        SnacksIndent = { fg = "highlight_med" },
        SnacksIndentChunk = { fg = "highlight_med" },
        SnacksIndentScope = { fg = "muted" },
        SnacksPickerBoxBorder = { fg = "surface", bg = "surface" },
        SnacksDiffDelete = { bg = "love", blend = 20 },
        SnacksDiffDeleteLineNr = { link = "SnacksDiffDelete" },

        -- lewis6991/gitsigns
        GitSignsAddInline = { bg = "foam", blend = 40 },
        GitSignsDeleteInline = { bg = "love", blend = 40 },
        GitSignsChangeInline = { bg = "gold", blend = 40 },
        GitSignsDeletePreview = { bg = "love", blend = 20 },
        GitSignsDeleteVirtLn = { link = "GitSignsDeletePreview" },

        -- mfussenegger/nvim-dap
        DapStoppedLine = { bg = "gold", blend = 20 },
      },
    },
    config = function(_, opts)
      require("rose-pine").setup(opts)
      vim.cmd([[colorscheme rose-pine]])
    end,
  },
}
