return {
  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    event = "BufReadPost",
    dependencies = {
      { "nvim-treesitter/nvim-treesitter-context", config = true },
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    build = ":TSUpdate",
    opts = {
      ensure_installed = "all",
      highlight = { enable = true },
      matchup = { enable = true },
      -- incremental_selection = {
      --   enable = true,
      --   keymaps = {
      --     init_selection = "<tab>",
      --     node_incremental = "<tab>",
      --     node_decremental = "<s-tab>",
      --   },
      -- },
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ic"] = "@class.inner",
            ["ac"] = "@class.outer",
            ["i,"] = "@parameter.inner",
            ["a,"] = "@parameter.outer",
          },
          include_surrounding_whitespace = false,
        },
        swap = {
          enable = true,
          swap_next = {
            ["<leader>>"] = "@parameter.inner",
          },
          swap_previous = {
            ["<leader><"] = "@parameter.inner",
          },
        },
      },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  },
}
