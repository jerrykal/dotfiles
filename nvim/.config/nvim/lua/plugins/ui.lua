return {
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
