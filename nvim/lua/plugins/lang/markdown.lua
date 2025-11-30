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

  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = {
      "nvim-treesitter",
      "mini.icons",
    },
    opts = {
      completions = { lsp = { enabled = true } },
      render_modes = true,
      sign = { enabled = false },
    },
  },
}
