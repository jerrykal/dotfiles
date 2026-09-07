return {
  -- Rose Pine color scheme with warm, muted tones
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
        -- This is all the italics I need :)
        Comment = { italic = true },
        ["@markup.italic"] = { italic = true },
        htmlItalic = { italic = true },

        WinBar = { fg = "subtle", bg = "base" },
        WinBarNC = { fg = "muted", bg = "base" },

        -- folke/snacks.nvim
        SnacksIndent = { fg = "highlight_med" },
        SnacksIndentChunk = { fg = "highlight_med" },
        SnacksIndentScope = { fg = "muted" },

        SnacksPicker = { fg = "subtle", bg = "base" },
        SnacksPickerBorder = { fg = "highlight_med", bg = "base" },
        SnacksPickerTitle = { fg = "muted", bg = "base" },
        SnacksPickerPrompt = { fg = "subtle" },
        SnacksPickerMatch = { fg = "rose", bold = false },
        SnacksPickerListCursorLine = { bg = "overlay" },
        SnacksPickerPreviewCursorLine = { bg = "overlay" },
        SnacksPickerTotals = { fg = "foam" },
        SnacksPickerSpinner = { fg = "gold" },
        SnacksPickerSelected = { fg = "love" },

        -- folke/trouble.nvim
        TroubleNormal = { bg = "base" },
        TroubleNormalNC = { bg = "base" },

        -- lewis6991/gitsigns
        GitSignsAddInline = { bg = "foam", blend = 40 },
        GitSignsDeleteInline = { bg = "love", blend = 40 },
        GitSignsChangeInline = { bg = "gold", blend = 40 },

        -- mfussenegger/nvim-dap
        DapStoppedLine = { bg = "gold", blend = 20 },

        -- Bekaboo/dropbar.nvim
        DropBarMenuNormalFloat = { fg = "subtle", bg = "surface" },
        DropBarMenuFloatBorder = { fg = "highlight_med", bg = "surface" },
        DropBarMenuCurrentContext = { fg = "text", bg = "highlight_high" },
        DropBarMenuHoverEntry = { fg = "text", bg = "overlay" },
        DropBarMenuHoverIcon = { bg = "overlay" },
        DropBarMenuHoverSymbol = { bg = "overlay", bold = true },
        DropBarCurrentContext = { bg = "overlay" },
        DropBarHover = { bg = "overlay" },
        DropBarPreview = { bg = "highlight_med" },
        DropBarFzfMatch = { fg = "rose" },
        DropBarIconUISeparator = { fg = "muted" },
        DropBarIconUISeparatorNC = { fg = "highlight_med" },
      },
    },
    config = function(_, opts)
      require("rose-pine").setup(opts)
      vim.cmd("colorscheme rose-pine")
    end,
  },
}
