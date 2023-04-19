return {
  -- File explorer
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v2.x",
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
            display_name = "  Git ",
          },
          {
            source = "git_status",
            display_name = " 裂Diagnostics ",
          },
        },
        content_layout = "center",
      },
      filesystem = {
        use_libuv_file_watcher = true,
        follow_current_file = true,
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
            hint = "  ",
            info = "  ",
            warn = "  ",
            error = "  ",
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

  -- Automatically resize window
  {
    "anuvyklack/windows.nvim",
    event = "WinNew",
    dependencies = {
      "anuvyklack/middleclass",
    },
    opts = function()
      vim.o.winwidth = 5
      vim.o.winminwidth = 5
      vim.o.equalalways = false
    end,
    config = true,
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
    opts = { filetypes_denylist = { "neo-tree" } },
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
  },

  -- Better diagnostics list and others
  {
    "folke/trouble.nvim",
    cmd = "TroubleToggle",
    config = true,
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
