return {
  {
    "nvim-lspconfig",
    opts = {
      servers = {
        basedpyright = {},
        ruff = {},
      },
    },
  },

  {
    "conform.nvim",
    formatters_by_ft = {
      python = { "ruff_fix", "ruff_organize_imports", "ruff_format" },
    },
  },
}
