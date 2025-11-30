return {
  {
    "mason.nvim",
    opts = {
      ensure_installed = { "shfmt" },
    },
  },

  {
    "nvim-lspconfig",
    opts = {
      servers = {
        bashls = {},
      },
    },
  },

  {
    "conform.nvim",
    opt = {
      formatters_by_ft = {
        sh = { "shfmt" },
      },
    },
  },
}
