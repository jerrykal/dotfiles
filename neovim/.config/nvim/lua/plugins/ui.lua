return {
  -- Icons
  { "kyazdani42/nvim-web-devicons" },

  -- UI components
  { "MunifTanjim/nui.nvim" },

  -- Floating winbar
  {
    "b0o/incline.nvim",
    event = "BufReadPre",
    config = function()
      local colors = require("kanagawa.colors").setup()
      require("incline").setup({
        hide = {
          only_win = true,
        },
        highlight = {
          groups = {
            InclineNormal = { guifg = colors.fg, guibg = colors.bg_light1 },
            InclineNormalNC = { guifg = colors.fg_comment, guibg = colors.bg_dark },
          },
        },
        window = { margin = { vertical = 0, horizontal = 1 } },
        render = function(props)
          local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
          local icon, color = require("nvim-web-devicons").get_icon_color(filename)
          return { { icon, guifg = color }, { " " }, { filename } }
        end,
      })
    end,
  },

  -- Bufferline
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    opts = function()
      -- Define colors for bufferline
      local colors = require("kanagawa.colors").setup()
      local fg_selected = colors.fg
      local fg_visible = colors.fg_comment
      local fg_inactive = colors.fg_comment
      local fg_error = colors.diag.error
      local fg_warning = colors.diag.warning
      local fg_info = colors.diag.info
      local fg_hint = colors.diag.hint
      local bg_selected = colors.bg_light1
      local bg_visible = colors.bg_light1
      local bg_inactive = colors.bg
      local bg_fill = colors.bg_dark

      return {
        options = {
          modified_icon = "",
          close_command = "Bdelete! %d",
          right_mouse_command = "Bdelete! %d",
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
              text = "File Explorer",
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
    opts = {
      char = "▏",
      context_char = "▏",
      show_current_context = true,
      filetype_exclude = { "neo-tree", "Trouble", "lazy" },
      buftype_exclude = { "terminal", "help", "prompt" },
    },
  },

  -- LSP symbol navigation for winbar
  {
    "SmiteshP/nvim-navic",
    lazy = true,
    opts = {
      icons = {
        File = " ",
        Module = " ",
        Namespace = " ",
        Package = " ",
        Class = " ",
        Method = " ",
        Property = " ",
        Field = " ",
        Constructor = " ",
        Enum = " ",
        Interface = " ",
        Function = " ",
        Variable = " ",
        Constant = " ",
        String = " ",
        Number = " ",
        Boolean = " ",
        Array = " ",
        Object = " ",
        Key = " ",
        Null = " ",
        EnumMember = " ",
        Struct = " ",
        Event = " ",
        Operator = " ",
        TypeParameter = " ",
      },
      highlight = true,
      separator = "  ",
    },
    init = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local buffer = args.buf
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client.server_capabilities.documentSymbolProvider then
            require("nvim-navic").attach(client, buffer)
            vim.wo.winbar = "  %{%v:lua.require'nvim-navic'.get_location()%}"
          end
        end,
      })
    end,
  },
}
