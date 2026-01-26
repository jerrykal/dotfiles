return {
  {
    "snacks.nvim",
    opts = {
      indent = {
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
      notifier = {},
      scope = {},
      statuscolumn = {
        left = { "sign", "mark" },
      },
      words = {},
      styles = {
        notification = {
          wo = { wrap = true },
        },
      },
    },
    -- stylua: ignore
    keys = {
      { "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications" },
      { "]]", function() Snacks.words.jump(vim.v.count1) end, desc = "Next Reference", mode = { "n", "t" } },
      { "[[", function() Snacks.words.jump(-vim.v.count1) end, desc = "Prev Reference", mode = { "n", "t" } },
      { "<a-n>", function() Snacks.words.jump(vim.v.count1) end, desc = "Next Reference", mode = { "n", "t" } },
      { "<a-p>", function() Snacks.words.jump(-vim.v.count1) end, desc = "Prev Reference", mode = { "n", "t" } },
    },
  },

  -- Fast icon provider for files, filetypes and other UI elements
  {
    "nvim-mini/mini.icons",
    lazy = true,
    opts = {},
    config = function(_, opts)
      require("mini.icons").setup(opts)
      MiniIcons.mock_nvim_web_devicons()
    end,
  },

  -- Display LSP diagnostics inline at end of line instead of virtual text
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "LazyFile",
    priority = 1000,
    opts = {
      preset = "powerline",
      options = {
        severity = {
          vim.diagnostic.severity.ERROR,
          vim.diagnostic.severity.WARN,
          vim.diagnostic.severity.INFO,
        },
        multilines = {
          enabled = true,
          severity = {
            vim.diagnostic.severity.ERROR,
            vim.diagnostic.severity.WARN,
            vim.diagnostic.severity.INFO,
          },
        },
      },
    },
  },

  -- LSP progress notifications in the corner of the editor
  {
    "j-hui/fidget.nvim",
    lazy = false,
    opts = {},
  },
}
