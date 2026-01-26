return {
  {
    "mason.nvim",
    opts = {
      ensure_installed = { "markdownlint-cli2", "markdown-toc" },
    },
  },

  {
    "nvim-lint",
    opts = {
      linters_by_ft = {
        markdown = { "markdownlint-cli2" },
      },
    },
  },

  {
    "conform.nvim",
    opts = {
      formatters_by_ft = {
        markdown = { "markdownlint-cli2", "markdown-toc" },
      },
    },
  },

  -- Live markdown rendering with proper formatting in the editor
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = "markdown",
    dependencies = {
      -- For toggling
      "snacks.nvim",
    },
    opts = {
      code = {
        width = "block",
        right_pad = 1,
      },
      heading = {
        icons = {},
      },
      sign = {
        enabled = false,
      },
    },
    config = function(_, opts)
      require("render-markdown").setup(opts)
      Snacks.toggle({
        name = "Render Markdown",
        get = require("render-markdown").get,
        set = require("render-markdown").set,
      }):map("<leader>um")
    end,
  },

  -- Live markdown preview in browser with synchronized scrolling
  {
    "toppair/peek.nvim",
    cond = vim.fn.executable("deno") == 1,
    build = "deno task --quiet build:fast",
    ft = { "markdown" },
    config = function()
      require("peek").setup()
      vim.api.nvim_create_user_command("PeekOpen", require("peek").open, {})
      vim.api.nvim_create_user_command("PeekClose", require("peek").close, {})
    end,
  },
}
