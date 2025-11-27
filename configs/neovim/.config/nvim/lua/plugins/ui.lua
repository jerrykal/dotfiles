return {
  {
    "nvim-mini/mini.icons",
    lazy = true,
    opts = {},
    config = function(_, opts)
      require("mini.icons").setup(opts)
      MiniIcons.mock_nvim_web_devicons()
    end,
  },

  -- Diagnostic virtual text on steroid
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "LazyFile",
    priority = 1000,
    opts = {
      preset = "powerline",
      options = {
        multilines = {
          enabled = true,
          always_show = true,
          severity = {
            vim.diagnostic.severity.ERROR,
            vim.diagnostic.severity.WARN,
          },
        },
      },
    },
  },

  -- {
  --   "Bekaboo/dropbar.nvim",
  --   event = "LazyFile",
  --   opts = {
  --     icons = {
  --       kinds = {
  --         symbols = {
  --           Folder = "",
  --           File = " ",
  --           Module = " ",
  --           Namespace = " ",
  --           Package = " ",
  --           Class = " ",
  --           Method = " ",
  --           Property = " ",
  --           Field = " ",
  --           Constructor = " ",
  --           Enum = " ",
  --           Interface = " ",
  --           Function = " ",
  --           Variable = " ",
  --           Constant = " ",
  --           String = " ",
  --           Number = " ",
  --           Boolean = " ",
  --           Array = " ",
  --           Object = " ",
  --           Key = " ",
  --           Null = " ",
  --           EnumMember = " ",
  --           Struct = " ",
  --           Event = " ",
  --           Operator = " ",
  --           TypeParameter = " ",
  --         },
  --       },
  --     },
  --   },
  --   config = function(_, opts)
  --     require("dropbar").setup(opts)
  --
  --     local dropbar_api = require("dropbar.api")
  --     vim.keymap.set("n", "<Leader>;", dropbar_api.pick, { desc = "Pick symbols in winbar" })
  --     vim.keymap.set("n", "[;", dropbar_api.goto_context_start, { desc = "Go to start of current context" })
  --     vim.keymap.set("n", "];", dropbar_api.select_next_context, { desc = "Select next context" })
  --   end,
  -- },
}
