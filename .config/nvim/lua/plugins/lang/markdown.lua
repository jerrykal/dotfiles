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
    "OXY2DEV/markview.nvim",
    lazy = false, -- markview.nvim lazy loads itself
    opts = {
      preview = {
        hybrid_modes = { "n", "no", "c" },
      },
    },
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
