return {
  -- Noice
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      cmdline = { enabled = false },
      messages = { enabled = false },
      lsp = { progress = { enabled = false } },
    },
  },

  -- Icons
  {
    "kyazdani42/nvim-web-devicons",
  },

  -- UI components
  { "MunifTanjim/nui.nvim" },

  -- Better vim.notify
  {
    "rcarriga/nvim-notify",
    lazy = false,
    opts = {
      stages = "static",
      timeout = 3000,
      on_open = function(win)
        vim.api.nvim_win_set_config(win, { border = "single" })
      end,
      max_height = function()
        return math.floor(vim.o.lines * 0.75)
      end,
      max_width = function()
        return math.floor(vim.o.columns * 0.75)
      end,
    },
    config = function(_, opts)
      require("notify").setup(opts)
      vim.notify = require("notify")
    end,
  },

  -- Bufferline
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    keys = {
      { "<leader>1", "<cmd>BufferLineGoToBuffer 1<cr>", desc = "Goto Buffer 1" },
      { "<leader>2", "<cmd>BufferLineGoToBuffer 2<cr>", desc = "Goto Buffer 2" },
      { "<leader>3", "<cmd>BufferLineGoToBuffer 3<cr>", desc = "Goto Buffer 3" },
      { "<leader>4", "<cmd>BufferLineGoToBuffer 4<cr>", desc = "Goto Buffer 4" },
      { "<leader>5", "<cmd>BufferLineGoToBuffer 5<cr>", desc = "Goto Buffer 5" },
      { "<leader>6", "<cmd>BufferLineGoToBuffer 6<cr>", desc = "Goto Buffer 6" },
      { "<leader>7", "<cmd>BufferLineGoToBuffer 7<cr>", desc = "Goto Buffer 7" },
      { "<leader>8", "<cmd>BufferLineGoToBuffer 8<cr>", desc = "Goto Buffer 8" },
      { "<leader>9", "<cmd>BufferLineGoToBuffer 9<cr>", desc = "Goto Buffer 9" },
      { "<leader>0", "<cmd>BufferLineGoToBuffer 10<cr>", desc = "Goto Buffer 10" },
      { "\\", "<cmd>BufferLinePick<cr>", desc = "Pick Buffer" },
      { "|", "<cmd>BufferLinePickClose<cr>", desc = "Close Buffer" },
      { "<s-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
      { "<s-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Previous Buffer" },
      { "<a-.>", "<cmd>BufferLineMoveNext<cr>", desc = "Move Buffer Right" },
      { "<a-,>", "<cmd>BufferLineMovePrev<cr>", desc = "Move Buffer Left" },
    },
    opts = function()
      -- Define colors for bufferline
      local colors = require("kanagawa.colors").setup()
      local fg_selected = colors.theme.ui.fg
      local fg_visible = colors.theme.syn.comment
      local fg_inactive = colors.theme.syn.comment
      local fg_error = colors.theme.diag.error
      local fg_warning = colors.theme.diag.warning
      local fg_info = colors.theme.diag.info
      local fg_hint = colors.theme.diag.hint
      local bg_selected = colors.theme.ui.bg_p2
      local bg_visible = colors.theme.ui.bg_p2
      local bg_inactive = colors.theme.ui.bg
      local bg_fill = colors.theme.ui.bg_m3

      return {
        options = {
          modified_icon = "",
          truncate_names = false,
          close_command = function(buffer)
            require("mini.bufremove").delete(buffer, true)
          end,
          right_mouse_command = function(buffer)
            require("mini.bufremove").delete(buffer, true)
          end,
          diagnostics = "nvim_lsp",
          diagnostics_update_in_insert = false,
          diagnostics_indicator = function(_, _, diagnostics_dict, _)
            local sum = 0
            for _, n in pairs(diagnostics_dict) do
              sum = sum + n
            end
            return " " .. (sum < 10 and tostring(sum) or "9+")
          end,
          offsets = {
            {
              filetype = "neo-tree",
              text = "EXPLORER",
              text_align = "center",
            },
            {
              filetype = "undotree",
              text = "Undotree",
              text_align = "center",
            },
          },
          show_close_icon = false,
          indicator = {
            style = "none",
          },
          hover = {
            enabled = true,
            delay = 0,
            reveal = { "close" },
          },
        },
        highlights = {
          background = { fg = fg_inactive, bg = bg_inactive, bold = false, italic = false },
          buffer_selected = { fg = fg_selected, bg = bg_selected, bold = false, italic = false },
          buffer_visible = { fg = fg_visible, bg = bg_visible, bold = false, italic = false },
          indicator_selected = { fg = fg_selected, bg = bg_selected, bold = false, italic = false },
          indicator_visible = { fg = fg_visible, bg = bg_visible, bold = false, italic = false },
          close_button = { fg = fg_inactive, bg = bg_inactive, bold = false, italic = false },
          close_button_selected = { fg = fg_selected, bg = bg_selected, bold = false, italic = false },
          close_button_visible = { fg = fg_visible, bg = bg_visible, bold = false, italic = false },
          diagnostic = { fg = fg_inactive, bg = bg_inactive, bold = false, italic = false },
          diagnostic_selected = { fg = fg_info, bg = bg_selected, bold = false, italic = false },
          diagnostic_visible = { fg = fg_visible, bg = bg_visible, bold = false, italic = false },
          duplicate = { fg = fg_inactive, bg = bg_inactive, bold = false, italic = false },
          duplicate_selected = { fg = fg_selected, bg = bg_selected, bold = false, italic = false },
          duplicate_visible = { fg = fg_visible, bg = bg_visible, bold = false, italic = false },
          error = { fg = fg_error, bg = bg_inactive, bold = false, italic = false },
          error_diagnostic = { fg = fg_error, bg = bg_inactive, bold = false, italic = false },
          error_diagnostic_selected = { fg = fg_error, bg = bg_selected, bold = false, italic = false },
          error_diagnostic_visible = { fg = fg_error, bg = bg_visible, bold = false, italic = false },
          error_selected = { fg = fg_error, bg = bg_selected, bold = false, italic = false },
          error_visible = { fg = fg_error, bg = bg_visible, bold = false, italic = false },
          fill = { bg = bg_fill, bold = false, italic = false },
          hint = { fg = fg_hint, bg = bg_inactive, bold = false, italic = false },
          hint_diagnostic = { fg = fg_hint, bg = bg_inactive, bold = false, italic = false },
          hint_diagnostic_selected = { fg = fg_hint, bg = bg_selected, bold = false, italic = false },
          hint_diagnostic_visible = { fg = fg_hint, bg = bg_visible, bold = false, italic = false },
          hint_selected = { fg = fg_hint, bg = bg_selected, bold = false, italic = false },
          hint_visible = { fg = fg_hint, bg = bg_visible, bold = false, italic = false },
          info = { fg = fg_info, bg = bg_inactive, bold = false, italic = false },
          info_diagnostic = { fg = fg_info, bg = bg_inactive, bold = false, italic = false },
          info_diagnostic_selected = { fg = fg_info, bg = bg_selected, bold = false, italic = false },
          info_diagnostic_visible = { fg = fg_info, bg = bg_visible, bold = false, italic = false },
          info_selected = { fg = fg_info, bg = bg_selected, bold = false, italic = false },
          info_visible = { fg = fg_info, bg = bg_visible, bold = false, italic = false },
          modified = { fg = fg_inactive, bg = bg_inactive, bold = false, italic = false },
          modified_selected = { fg = fg_selected, bg = bg_selected, bold = false, italic = false },
          modified_visible = { fg = fg_visible, bg = bg_visible, bold = false, italic = false },
          pick = { bg = bg_inactive, bold = false, italic = false },
          pick_selected = { bg = bg_selected, bold = false, italic = false },
          pick_visible = { bg = bg_visible, bold = false, italic = false },
          separator = { fg = bg_fill, bg = bg_inactive, bold = false, italic = false },
          separator_selected = { fg = bg_fill, bg = bg_selected, bold = false, italic = false },
          separator_visible = { fg = bg_fill, bg = bg_visible, bold = false, italic = false },
          tab = { fg = fg_inactive, bg = bg_inactive, bold = false, italic = false },
          tab_close = { bg = bg_fill, bold = false, italic = false },
          tab_selected = { fg = fg_selected, bg = bg_selected, bold = false, italic = false },
          warning = { fg = fg_warning, bg = bg_inactive, bold = false, italic = false },
          warning_diagnostic = { fg = fg_warning, bg = bg_inactive, bold = false, italic = false },
          warning_diagnostic_selected = { fg = fg_warning, bg = bg_selected, bold = false, italic = false },
          warning_diagnostic_visible = { fg = fg_warning, bg = bg_visible, bold = false, italic = false },
          warning_selected = { fg = fg_warning, bg = bg_selected, bold = false, italic = false },
          warning_visible = { fg = fg_warning, bg = bg_visible, bold = false, italic = false },
        },
      }
    end,
  },

  -- Indent guides
  {
    "lukas-reineke/indent-blankline.nvim",
    event = "BufReadPre",
    version = "2.*",
    opts = {
      char = "▏",
      context_char = "▏",
      show_current_context = true,
      filetype_exclude = { "neo-tree", "Trouble", "lazy", "help", "mason" },
    },
  },

  -- LSP symbol navigation for winbar
  {
    "utilyre/barbecue.nvim",
    event = "BufReadPre",
    dependencies = {
      "SmiteshP/nvim-navic",
    },
    opts = {},
  },

  -- Zen mode
  {
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
    keys = { { "<leader>z", "<cmd>ZenMode<cr>", desc = "Zen Mode" } },
    opts = {
      plugins = {
        gitsigns = true,
      },
    },
  },

  -- Automatically resize window
  {
    "anuvyklack/windows.nvim",
    event = "WinNew",
    dependencies = {
      "anuvyklack/middleclass",
    },
    keys = {
      { "<c-w>z", "<cmd>WindowsMaximize<cr>", desc = "Maximize Current Window" },
      { "<c-w>_", "<cmd>WindowsMaximizeVertically<cr>", desc = "Maximize Current Window Vertically" },
      { "<c-w>|", "<cmd>WindowsMaximizeHorizontally<cr>", desc = "Maximize Current Window Horizontally" },
      { "<c-w>=", "<cmd>WindowsEqualize<cr>", desc = "Equalize Windows" },
    },
    opts = {
      autowidth = {
        enable = false,
      },
      animation = {
        enable = false,
      },
    },
    config = function(_, opts)
      vim.o.winwidth = 5
      vim.o.winminwidth = 5
      vim.o.equalalways = false
      require("windows").setup(opts)
    end,
  },

  -- Automatically switch between relative and absolute line numbers
  {
    "cpea2506/relative-toggle.nvim",
    event = "BufReadPre",
    opts = {},
  },
}
