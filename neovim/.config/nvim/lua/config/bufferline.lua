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

require("bufferline").setup({
  options = {
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
})
