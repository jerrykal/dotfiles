return {
  {
    "mason.nvim",
    opts = {
      ensure_installed = {
        "shfmt",
        "shellcheck",
      },
    },
  },

  {
    "nvim-lspconfig",
    opts = {
      servers = {
        bashls = {
          filetypes = { "sh", "zsh" },
        },
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
