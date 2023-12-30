return {
  -- File explorer
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    keys = {
      { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Toggle Neotree" },
    },
    opts = {
      close_if_last_window = true,
      enable_modified_markers = false,
      use_popups_for_input = false,
      source_selector = {
        winbar = true,
        sources = {
          {
            source = "filesystem",
            display_name = "  Files ",
          },
          {
            display_name = "  Buffers ",
          },
          {
            source = "buffers",
            display_name = "  Git ",
          },
          {
            source = "git_status",
            display_name = " 󰒡 Diagnostics ",
          },
        },
        content_layout = "center",
      },
      filesystem = {
        use_libuv_file_watcher = true,
        follow_current_file = {
          enable = true,
        },
        filtered_items = {
          visible = true,
          hide_dotfiles = false,
          hide_gitignored = true,
        },
      },
      default_component_configs = {
        indent = {
          with_expanders = true,
          expander_collapsed = "",
          expander_expanded = "",
        },
        icon = {
          folder_closed = "",
          folder_open = "",
          folder_empty = "",
          folder_empty_open = "",
          default = "",
        },
        git_status = {
          symbols = {
            added = "A",
            deleted = "D",
            modified = "M",
            renamed = "R",
            untracked = "U",
            ignored = "",
            unstaged = "",
            staged = "",
          },
        },
        diagnostics = {
          symbols = {
            hint = "  ",
            info = "  ",
            warn = "  ",
            error = "  ",
          },
          highlights = {
            hint = "DiagnosticSignHint",
            info = "DiagnosticSignInfo",
            warn = "DiagnosticSignWarn",
            error = "DiagnosticSignError",
          },
        },
      },
    },
  },

  -- Open terminal in splitscreen
  {
    "akinsho/toggleterm.nvim",
    keys = "<c-\\>",
    opts = {
      open_mapping = [[<c-\>]],
      direction = "float",
      highlights = {
        FloatBorder = {
          link = "FloatBorder",
        },
      },
      size = 15,
      persist_size = true,
      shade_terminals = false,
      auto_scroll = false,
    },
  },

  -- TODO: comments
  {
    "folke/todo-comments.nvim",
    event = "BufReadPost",
    opts = {
      signs = false,
    },
  },

  -- Enhanced search and navigation
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    -- stylua: ignore
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "o", "x" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
    opts = {
      search = {
        exclude = {
          "cmp_menu",
          "flash_prompt",
          "neo-tree",
          "noice",
          "notify",
          function(win)
            -- exclude non-focusable windows
            return not vim.api.nvim_win_get_config(win).focusable
          end,
        },
      },
      highlight = {
        backdrop = false,
      },
      modes = {
        search = {
          enabled = false,
        },
        char = {
          highlight = {
            backdrop = false,
          },
        },
      },
    },
  },

  -- Automatically highlighting other uses of the word under the cursor
  {
    "RRethy/vim-illuminate",
    event = "BufReadPre",
    opts = { filetypes_denylist = { "neo-tree", "aerial" } },
    config = function(_, opts)
      require("illuminate").configure(opts)
    end,
  },

  -- Delete buffer
  {
    "echasnovski/mini.bufremove",
    keys = {
      { "<leader>x", "<cmd>lua require('mini.bufremove').delete(0, false)<cr>", desc = "Close Buffer" },
      { "<leader>X", "<cmd>lua require('mini.bufremove').delete(0, true)<cr>", desc = "Close Buffer (force)" },
    },
    config = function()
      require("mini.bufremove").setup()
    end,
  },

  -- Better diagnostics list and others
  {
    "folke/trouble.nvim",
    cmd = { "TroubleToggle", "Trouble" },
    keys = {
      { "<leader>tt", "<cmd>TroubleToggle<cr>", desc = "Toggle Trouble" },
      { "<leader>tw", "<cmd>TroubleToggle workspace_diagnostics<cr>", desc = "Workspace Diagnostic (Trouble)" },
      { "<leader>td", "<cmd>TroubleToggle document_diagnostics<cr>", desc = "Document Diagnostic (Trouble)" },
      { "<leader>tl", "<cmd>TroubleToggle loclist<cr>", desc = "Location List (Trouble)" },
      { "<leader>tq", "<cmd>TroubleToggle quickfix<cr>", desc = "Quickfix List (Trouble)" },
      { "gR", "<cmd>TroubleToggle lsp_references<cr>", desc = "Lsp References (Trouble)" },
    },
    config = true,
  },

  -- Git diff
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles" },
    opts = {},
    keys = { { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "DiffView" } },
  },

  -- Better matchit/paren
  {
    "andymass/vim-matchup",
    event = "BufReadPre",
    config = function()
      vim.g.matchup_matchparen_offscreen = { method = "popup" }
    end,
  },

  -- which-key
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      spelling = {
        enable = true,
      },
      icons = {
        breadcrumb = "",
        separator = " ",
      },
      window = {
        winblend = 10,
      },
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      wk.register({
        mode = { "n", "v" },
        ["<leader>c"] = { name = "+code" },
        ["<leader>f"] = { name = "+find" },
        ["<leader>h"] = { name = "+git_hunk" },
        ["<leader>r"] = { name = "+rename" },
        ["<leader>t"] = { name = "+trouble" },
        ["<leader>u"] = { name = "+ui" },
      })
    end,
  },
}
