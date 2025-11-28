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
}
