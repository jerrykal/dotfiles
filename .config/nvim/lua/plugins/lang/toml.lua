return {
  {
    "nvim-lspconfig",
    opts = {
      servers = {
        taplo = {},
      },
    },
  },

  {
    "conform.nvim",
    opts = {
      formatters_by_ft = {
        -- Taplo lsp crashes sometime, so set formatter here to ensure formatting still works when it crashes
        toml = { "taplo" },
      },
    },
  },
}
