return {
  {
    "rebelot/kanagawa.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      local c = require("kanagawa.lib.color")
      require("kanagawa").setup({
        globalStatus = true,
        colors = {
          theme = {
            wave = {
              ui = {
                bg_gutter = "#1F1F28",
              },
            },
          },
        },
        overrides = function(colors)
          local palette = colors.palette
          local theme = colors.theme
          return {
            -- Have to add this line to make pumblend work
            NormalNC = { bg = theme.ui.bg },

            CursorLine = { bg = theme.ui.bg },
            CursorLineNr = { fg = theme.ui.special },
            FloatBorder = { fg = theme.ui.whitespace, bg = theme.ui.bg },
            Search = { fg = "NONE", bg = theme.ui.bg_search },

            ["@constructor"] = { fg = theme.syn.type },
            TreesitterContext = { bg = theme.ui.bg_dim },

            debugBreakpoint = { fg = palette.samuraiRed },
            debugPC = { bg = theme.diff.text },

            TelescopeTitle = { fg = theme.ui.special, bold = true },
            TelescopePromptNormal = { bg = theme.ui.bg_p1 },
            TelescopePromptBorder = { fg = theme.ui.bg_p1, bg = theme.ui.bg_p1 },
            TelescopeResultsNormal = { fg = theme.ui.fg_dim, bg = theme.ui.bg_m1 },
            TelescopeResultsBorder = { fg = theme.ui.bg_m1, bg = theme.ui.bg_m1 },
            TelescopePreviewNormal = { bg = theme.ui.bg_dim },
            TelescopePreviewBorder = { bg = theme.ui.bg_dim, fg = theme.ui.bg_dim },
            TelescopeSelection = { bg = theme.ui.bg_visual },

            CmpItemAbbr = { fg = theme.ui.pmenu.fg, bg = "None" },
            CmpItemAbbrDeprecated = { fg = theme.syn.comment, bg = "None", strikethrough = true },
            CmpItemAbbrMatch = { fg = theme.syn.fun, bg = "None" },
            CmpItemAbbrMatchFuzzy = { link = "CmpItemAbbrMatch" },
            CmpItemKindClass = { fg = palette.surimiOrange },
            CmpItemKindConstant = { fg = palette.oniViolet },
            CmpItemKindConstructor = { fg = palette.surimiOrange },
            CmpItemKindEnum = { fg = palette.boatYellow2 },
            CmpItemKindEnumMember = { fg = palette.carpYellow },
            CmpItemKindField = { fg = palette.waveAqua1 },
            CmpItemKindFile = { fg = palette.springViolet2 },
            CmpItemKindFunction = { fg = palette.crystalBlue },
            CmpItemKindInterface = { fg = palette.carpYellow },
            CmpItemKindKeyword = { fg = palette.oniViolet },
            CmpItemKindMethod = { fg = palette.crystalBlue },
            CmpItemKindModule = { fg = palette.boatYellow2 },
            CmpItemKindOperator = { fg = palette.springViolet2 },
            CmpItemKindProperty = { fg = palette.waveAqua2 },
            CmpItemKindStruct = { fg = palette.surimiOrange },
            CmpItemKindTypeParameter = { fg = palette.springBlue },
            CmpItemKindVariable = { fg = palette.oniViolet },

            NavicIconsArray = { fg = palette.waveAqua2 },
            NavicIconsBoolean = { fg = palette.surimiOrange },
            NavicIconsClass = { fg = palette.surimiOrange },
            NavicIconsConstant = { fg = palette.oniViolet },
            NavicIconsConstructor = { fg = palette.surimiOrange },
            NavicIconsEnum = { fg = palette.boatYellow2 },
            NavicIconsEnumMember = { fg = palette.carpYellow },
            NavicIconsEvent = { fg = palette.surimiOrange },
            NavicIconsField = { fg = palette.waveAqua1 },
            NavicIconsFile = { fg = palette.springViolet2 },
            NavicIconsFunction = { fg = palette.crystalBlue },
            NavicIconsInterface = { fg = palette.carpYellow },
            NavicIconsKey = { fg = palette.oniViolet },
            NavicIconsMethod = { fg = palette.crystalBlue },
            NavicIconsModule = { fg = palette.boatYellow2 },
            NavicIconsNamespace = { fg = palette.springViolet2 },
            NavicIconsNull = { fg = palette.carpYellow },
            NavicIconsNumber = { fg = palette.sakuraPink },
            NavicIconsObject = { fg = palette.surimiOrange },
            NavicIconsOperator = { fg = palette.springViolet2 },
            NavicIconsPackage = { fg = palette.springViolet1 },
            NavicIconsProperty = { fg = palette.waveAqua2 },
            NavicIconsString = { fg = palette.springGreen },
            NavicIconsStruct = { fg = palette.surimiOrange },
            NavicIconsTypeParameter = { fg = palette.springBlue },
            NavicIconsVariable = { fg = palette.oniViolet },
            NavicSeparator = { fg = theme.ui.whitespace },
            NavicText = { fg = tostring(c(theme.ui.whitespace):brighten(0.3)) },

            IlluminatedWordText = { bg = theme.ui.bg_p2 },
            IlluminatedWordRead = { bg = theme.ui.bg_p2 },
            IlluminatedWordWrite = { bg = theme.ui.bg_p2 },

            NeoTreeDimText = { fg = theme.ui.whitespace },
            NeoTreeDotfile = { fg = theme.syn.comment },
            NeoTreeDirectoryName = { fg = theme.ui.fg },
            NeoTreeFileIcon = { fg = theme.ui.fg },
            NeoTreeTabInactive = { fg = theme.syn.comment, bg = theme.ui.bg },
            NeoTreeTabActive = { fg = theme.ui.fg, bg = theme.ui.bg_p2 },
            NeoTreeTabSeparatorInactive = { fg = theme.ui.bg_m3, bg = theme.ui.bg },
            NeoTreeTabSeparatorActive = { fg = theme.ui.bg_m3, bg = theme.ui.bg_p2 },
            NeoTreeGitUntracked = { link = "GitSignsAdd" },
            NeoTreeCursorLine = { bg = theme.ui.bg },

            IndentBlanklineChar = { fg = theme.ui.bg_p2 },
            IndentBlanklineSpaceChar = { fg = theme.ui.bg_p2 },
            IndentBlanklineSpaceCharBlankline = { fg = theme.ui.bg_p2 },
            IndentBlanklineContextChar = { fg = theme.ui.whitespace },

            NotifyERRORBorder = { link = "FloatBorder" },
            NotifyWARNBorder = { link = "FloatBorder" },
            NotifyINFOBorder = { link = "FloatBorder" },
            NotifyDEBUGBorder = { link = "FloatBorder" },
            NotifyTRACEBorder = { link = "FloatBorder" },

            DiagnosticUnnecessary = {},
          }
        end,
      })

      vim.cmd("colorscheme kanagawa")
    end,
  },
}
