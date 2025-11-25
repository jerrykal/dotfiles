return {
  -- Better yank/paste
  {
    "gbprod/yanky.nvim",
    dependencies = {
      "kkharji/sqlite.lua",
      "folke/snacks.nvim",
    },
    event = "LazyFile",
    opts = {
      ring = {
        storage = "sqlite",
        update_register_on_cycle = true,
      },
      highlight = {
        timer = 150,
      },
    },
    keys = {
      {
        "<leader>p",
        function()
          if not vim.g.vscode then
            Snacks.picker.yanky()
          else
            vim.cmd([[YankyRingHistory]])
          end
        end,
        mode = { "n", "x" },
        desc = "Open yank history",
      },
      -- stylua: ignore
      { "y", "<plug>(YankyYank)", mode = { "n", "x" }, desc = "Yank text" },
      { "p", "<plug>(YankyPutAfter)", mode = { "n", "x" }, desc = "Put yanked text after cursor" },
      { "P", "<plug>(YankyPutBefore)", mode = { "n", "x" }, desc = "Put yanked text before cursor" },
      { "gp", "<plug>(YankyGPutAfter)", mode = { "n", "x" }, desc = "Put yanked text after selection" },
      { "gP", "<plug>(YankyGPutBefore)", mode = { "n", "x" }, desc = "Put yanked text before selection" },
      { "[y", "<plug>(YankyPreviousEntry)", desc = "Select previous entry through yank history" },
      { "]y", "<plug>(YankyNextEntry)", desc = "Select next entry through yank history" },
      { "]p", "<plug>(YankyPutIndentAfterLinewise)", desc = "Put indented after cursor (linewise)" },
      { "[p", "<plug>(YankyPutIndentBeforeLinewise)", desc = "Put indented before cursor (linewise)" },
      { "]P", "<plug>(YankyPutIndentAfterLinewise)", desc = "Put indented after cursor (linewise)" },
      { "[P", "<plug>(YankyPutIndentBeforeLinewise)", desc = "Put indented before cursor (linewise)" },
      { ">p", "<plug>(YankyPutIndentAfterShiftRight)", desc = "Put and indent right" },
      { "<p", "<plug>(YankyPutIndentAfterShiftLeft)", desc = "Put and indent left" },
      { ">P", "<plug>(YankyPutIndentBeforeShiftRight)", desc = "Put before and indent right" },
      { "<P", "<plug>(YankyPutIndentBeforeShiftLeft)", desc = "Put before and indent left" },
      { "=p", "<plug>(YankyPutAfterFilter)", desc = "Put after applying a filter" },
      { "=P", "<plug>(YankyPutBeforeFilter)", desc = "Put before applying a filter" },
    },
  },

  {
    "nvim-mini/mini.surround",
    opts = {
      mappings = {
        add = "gs", -- Add surrounding in Normal and Visual modes
        delete = "gsd", -- Delete surrounding
        find = "gsf", -- Find surrounding (to the right)
        find_left = "gsF", -- Find surrounding (to the left)
        highlight = "gsh", -- Highlight surrounding
        replace = "gsr", -- Replace surrounding
        update_n_lines = "gsn", -- Update `n_lines`
      },
    },
  },

  {
    "nvim-mini/mini.comment",
    event = "VeryLazy",
    opts = {},
  },

  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {},
  },

  {
    "folke/ts-comments.nvim",
    event = "VeryLazy",
    opts = {},
  },

  {
    "chrisgrieser/nvim-various-textobjs",
    event = "LazyFile",
    opts = {
      keymaps = {
        useDefaults = true,
      },
    },
  },

  -- Neovim lua_ls setup
  {
    "folke/lazydev.nvim",
    ft = "lua",
    cmd = "LazyDev",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        { path = "LazyVim", words = { "LazyVim" } },
        { path = "snacks.nvim", words = { "Snacks" } },
        { path = "lazy.nvim", words = { "LazyVim" } },
      },
    },
  },
}
