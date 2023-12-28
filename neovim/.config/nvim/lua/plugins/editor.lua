return {
  -- File explorer
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
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
    keys = {
      { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Toggle Neotree" },
    },
  },

  -- Open terminal in splitscreen
  {
    "akinsho/toggleterm.nvim",
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
    keys = "<c-\\>",
  },

  -- TODO: comments
  {
    "folke/todo-comments.nvim",
    event = "BufReadPost",
    opts = {
      signs = false,
    },
  },

  -- Jump to any location with ease
  {
    "ggandor/leap.nvim",
    event = "BufReadPost",
    config = function()
      require("leap").add_default_mappings()
    end,
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
    config = function()
      require("mini.bufremove").setup()
    end,
    keys = {
      { "<leader>x", "<cmd>lua require('mini.bufremove').delete(0, false)<cr>", desc = "Close Buffer" },
      { "<leader>X", "<cmd>lua require('mini.bufremove').delete(0, true)<cr>", desc = "Close Buffer (force)" },
    },
  },

  -- Better diagnostics list and others
  {
    "folke/trouble.nvim",
    cmd = { "TroubleToggle", "Trouble" },
    config = true,
    keys = {
      { "<leader>tt", "<cmd>TroubleToggle<cr>", desc = "Toggle Trouble" },
      {
        "<leader>tw",
        "<cmd>TroubleToggle workspace_diagnostics<cr>",
        desc = "Workspace Diagnostic (Trouble)",
      },
      {
        "<leader>td",
        "<cmd>TroubleToggle document_diagnostics<cr>",
        desc = "Document Diagnostic (Trouble)",
      },
      {
        "<leader>tl",
        "<cmd>TroubleToggle loclist<cr>",
        desc = "Location List (Trouble)",
      },
      {
        "<leader>tq",
        "<cmd>TroubleToggle quickfix<cr>",
        desc = "Quickfix List (Trouble)",
      },
      {
        "gR",
        "<cmd>TroubleToggle lsp_references<cr>",
        desc = "Lsp References (Trouble)",
      },
    },
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
        ["<leader>c"] = { name = "+code" },
        ["<leader>d"] = { name = "+debugger" },
        ["<leader>f"] = { name = "+file/find" },
        ["<leader>h"] = { name = "+git_hunk" },
        ["<leader>m"] = { name = "+markdown" },
        ["<leader>r"] = { name = "+rename" },
        ["<leader>s"] = { name = "+search" },
        ["<leader>t"] = { name = "+trouble" },
        ["<leader>w"] = { name = "+workspace" },
        ["cs"] = { name = "Change Surrounding" },
        ["ds"] = { name = "Delete Surrounding" },
        ["gp"] = { name = "+preview" },
        ["ys"] = { name = "Yank Surrounding" },
      })
    end,
  },
}
