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
        TreesitterContext = { bg = "base" },
        TreesitterContextLineNumber = { bg = "base" },

        -- folke/snacks.nvim
        SnacksIndentScope = { fg = "muted" },
        SnacksIndent = { fg = "highlight_med" },
        SnacksIndentChunk = { fg = "highlight_med" },
        SnacksDiffDelete = { bg = "love", blend = 20 },
        SnacksDiffDeleteLineNr = { link = "SnacksDiffDelete" },

        -- lewis6991/gitsigns
        GitSignsAddInline = { bg = "foam", blend = 40 },
        GitSignsDeleteInline = { bg = "love", blend = 40 },
        GitSignsChangeInline = { bg = "gold", blend = 40 },
        GitSignsDeletePreview = { bg = "love", blend = 20 },
        GitSignsDeleteVirtLn = { link = "GitSignsDeletePreview" },

        -- Bekaboo/dropbar.nvim
        DropBarIconKindArray = { link = "NavicIconsArray" },
        DropBarIconKindBoolean = { link = "NavicIconsBoolean" },
        DropBarIconKindClass = { link = "NavicIconsClass" },
        DropBarIconKindConstant = { link = "NavicIconsConstant" },
        DropBarIconKindConstructor = { link = "NavicIconsConstructor" },
        DropBarIconKindEnum = { link = "NavicIconsEnum" },
        DropBarIconKindEnumMember = { link = "NavicIconsEnumMember" },
        DropBarIconKindEvent = { link = "NavicIconsEvent" },
        DropBarIconKindField = { link = "NavicIconsField" },
        DropBarIconKindFile = { link = "NavicIconsFile" },
        DropBarIconKindFunction = { link = "NavicIconsFunction" },
        DropBarIconKindInterface = { link = "NavicIconsInterface" },
        DropBarIconKindKey = { link = "NavicIconsKey" },
        DropBarIconKindKeyword = { link = "NavicIconsKeyword" },
        DropBarIconKindMethod = { link = "NavicIconsMethod" },
        DropBarIconKindModule = { link = "NavicIconsModule" },
        DropBarIconKindNamespace = { link = "NavicIconsNamespace" },
        DropBarIconKindNull = { link = "NavicIconsNull" },
        DropBarIconKindNumber = { link = "NavicIconsNumber" },
        DropBarIconKindObject = { link = "NavicIconsObject" },
        DropBarIconKindOperator = { link = "NavicIconsOperator" },
        DropBarIconKindPackage = { link = "NavicIconsPackage" },
        DropBarIconKindProperty = { link = "NavicIconsProperty" },
        DropBarIconKindString = { link = "NavicIconsString" },
        DropBarIconKindStruct = { link = "NavicIconsStruct" },
        DropBarIconKindTypeParameter = { link = "NavicIconsTypeParameter" },
        DropBarIconKindVariable = { link = "NavicIconsVariable" },
        DropBarIconUISeparatorNC = { fg = "muted" },
        DropBarMenuHoverEntry = { bg = "highlight_med" },
      },
    },
    config = function(_, opts)
      require("rose-pine").setup(opts)
      vim.cmd([[colorscheme rose-pine]])
    end,
  },
}
