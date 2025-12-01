return {
  {
    "snacks.nvim",
    opts = {
      indent = {
        enable = true,
        indent = {
          char = "▏",
        },
        scope = {
          char = "▏",
        },
        animate = {
          enabled = false,
        },
      },
      input = { enabled = true },
      notifier = { enabled = true },
      scope = { enabled = true },
      statuscolumn = { enabled = true },
      words = { enabled = true },
    },
    -- stylua: ignore
    keys = {
      { "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications" },
      { "]]", function() Snacks.words.jump(vim.v.count1) end, desc = "Next Reference", mode = { "n", "t" } },
      { "[[", function() Snacks.words.jump(-vim.v.count1) end, desc = "Prev Reference", mode = { "n", "t" } },
    },
  },

  {
    "nvim-mini/mini.icons",
    lazy = true,
    opts = {},
    config = function(_, opts)
      require("mini.icons").setup(opts)
      MiniIcons.mock_nvim_web_devicons()
    end,
  },

  {
    "j-hui/fidget.nvim",
    lazy = true,
    opts = {},
  },

  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "LazyFile",
    priority = 1000,
    opts = {
      preset = "powerline",
      options = {
        multilines = {
          enabled = true,
          severity = {
            vim.diagnostic.severity.ERROR,
            vim.diagnostic.severity.WARN,
          },
        },
      },
    },
  },

  {
    "SmiteshP/nvim-navic",
    dependencies = { "folke/snacks.nvim" },
    lazy = true,
    opts = {
      lsp = {
        auto_attach = true,
      },
      highlight = true,
      separator = "  ",
      depth_limit_indicator = "…",
      click = true,
      icons = {
        File = " ",
        Module = " ",
        Namespace = " ",
        Package = " ",
        Class = " ",
        Method = " ",
        Property = " ",
        Field = " ",
        Constructor = " ",
        Enum = " ",
        Interface = " ",
        Function = " ",
        Variable = " ",
        Constant = " ",
        String = " ",
        Number = " ",
        Boolean = " ",
        Array = " ",
        Object = " ",
        Key = " ",
        Null = " ",
        EnumMember = " ",
        Struct = " ",
        Event = " ",
        Operator = " ",
        TypeParameter = " ",
      },
    },
    config = function(_, opts)
      require("nvim-navic").setup(opts)

      Snacks.util.lsp.on({ method = "textDocument/documentSymbol" }, function(buf)
        if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "" then
          for _, win in ipairs(vim.fn.win_findbuf(buf)) do
            vim.wo[win][0].winbar = "  %{%v:lua.require'nvim-navic'.get_location()%}  "
          end
        end
      end)
    end,
  },
}
