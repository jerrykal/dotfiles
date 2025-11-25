return {
  {
    "rose-pine/neovim",
    name = "rose-pine",
    priority = 1000,
    opts = {
      highlight_groups = {
        IblScope = { fg = "muted" },
        IblIndent = { fg = "highlight_med" },
        IblWhitespace = { fg = "highlight_med" },
      },
    },
    config = function(_, opts)
      require("rose-pine").setup(opts)
      vim.cmd([[colorscheme rose-pine]])
    end,
  },
}
