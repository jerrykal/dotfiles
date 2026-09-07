return {
  {
    "nvim-treesitter",
    opts = { ensure_installed = { "fish" } },
  },

  {
    "nvim-lspconfig",
    opts = {
      servers = {
        fish_lsp = {},
      },
    },
  },
}
