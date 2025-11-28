return {
  { "folke/lazy.nvim", version = "*" },

  -- Main plugin specification for snacks.nvim
  {
    "folke/snacks.nvim",
    lazy = false,
    priority = 999,
    dependencies = { "mini.icons" },
    opts_extend = { "styles" },
    opts = {},
  },
}
