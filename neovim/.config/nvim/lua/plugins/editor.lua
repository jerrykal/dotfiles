return {
  -- File explorer
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v2.x",
    cmd = "Neotree",
    opts = {
      enable_modified_markers = false,
      use_popups_for_input = false,
      source_selector = {
        winbar = true,
        tab_labels = {
          filesystem = "  Files ",
          buffers = "  Buffers ",
          git_status = "  Git ",
          diagnostics = " 裂Diagnostics ",
        },
        content_layout = "center",
      },
      filesystem = {
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

  -- Telescope
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        config = function()
          require("telescope").load_extension("fzf")
        end,
      },
    },
    cmd = "Telescope",
    opts = {
      defaults = {
        cycle_layout_list = { "horizontal", "vertical" },
        pickers = {
          live_grep = {
            -- Search hidden files
            additional_args = function(_)
              return { "--hidden" }
            end,
          },
        },
        layout_config = {
          vertical = {
            preview_height = 0.5,
          },
          flex = {
            flip_columns = 160,
          },
          horizontal = {
            preview_width = 0.5,
          },
          height = 0.85,
          width = 0.85,
          preview_cutoff = 0,
        },
        vimgrep_arguments = {
          "rg",
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "--smart-case",
          "--hidden",
        },
        prompt_prefix = "   ",
        selection_caret = "  ",
        entry_prefix = "  ",
        layout_strategy = "flex",
        file_ignore_patterns = {
          ".git",
          "node_modules",
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
      size = 15,
      persist_size = true,
      shade_terminals = false,
    },
  },

  -- Jump to any location with ease
  {
    "ggandor/leap.nvim",
    keys = { "gs", "s", "S" },
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
    "famiu/bufdelete.nvim",
    cmd = { "Bdelete", "Bwipeout" },
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
    event = "BufReadPost",
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
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      wk.register({
        ["cs"] = { name = "Change Surrounding" },
        ["ds"] = { name = "Delete Surrounding" },
        ["ys"] = { name = "Yank Surrounding" },
        ["gp"] = { name = "+preview" },
        ["<leader>c"] = { name = "+code" },
        ["<leader>h"] = { name = "+git hunk" },
        ["<leader>r"] = { name = "+re" },
        ["<leader>f"] = { name = "+file/find" },
        ["<leader>t"] = { name = "+trouble" },
        ["<leader>w"] = { name = "+workspace" },
      })
    end,
  },

  {
    "luukvbaal/stabilize.nvim",
    event = "BufNew",
    config = true,
  }
}
