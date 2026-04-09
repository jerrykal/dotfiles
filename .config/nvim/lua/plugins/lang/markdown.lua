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
}
