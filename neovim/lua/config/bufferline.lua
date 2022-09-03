local hl = {}
if packer_plugins['vscode.nvim'] and packer_plugins['vscode.nvim'].loaded then
  local c = require('vscode.colors')
  local fg_selected = c.vscFront
  local fg_visible = c.vscGray
  local fg_inactive = c.vscGray
  local fg_error = c.vscRed
  local fg_warning = c.vscYellow
  local fg_info = c.vscBlue
  local fg_hint = c.vscBlue
  local bg_selected = c.vscTabCurrent
  local bg_visible = c.vscTabCurrent
  local bg_inactive = c.vscTabOther
  local bg_fill = c.vscLeftDark

  hl.background = {fg = fg_inactive, bg = bg_inactive, bold = false, italic = false}
  hl.buffer_selected = {fg = fg_selected, bg = bg_selected, bold = false, italic = false}
  hl.buffer_visible = {fg = fg_visible, bg = bg_visible, bold = false, italic = false}
  hl.close_button = {fg = fg_inactive, bg = bg_inactive, bold = false, italic = false}
  hl.close_button_selected = {fg = fg_selected, bg = bg_selected, bold = false, italic = false}
  hl.close_button_visible = {fg = fg_visible, bg = bg_visible, bold = false, italic = false}
  hl.diagnostic = {fg = fg_inactive, bg = bg_inactive, bold = false, italic = false}
  hl.diagnostic_selected = {fg = fg_info, bg = bg_selected, bold = false, italic = false}
  hl.diagnostic_visible = {fg = fg_visible, bg = bg_visible, bold = false, italic = false}
  hl.duplicate = {fg = fg_inactive, bg = bg_inactive, bold = false, italic = false}
  hl.duplicate_selected = {fg = fg_selected, bg = bg_selected, bold = false, italic = false}
  hl.duplicate_visible = {fg = fg_visible, bg = bg_visible, bold = false, italic = false}
  hl.error = {fg = fg_inactive, bg = bg_inactive, bold = false, italic = false}
  hl.error_diagnostic = {fg = fg_inactive, bg = bg_inactive, bold = false, italic = false}
  hl.error_diagnostic_selected = {fg = fg_error, bg = bg_selected, bold = false, italic = false}
  hl.error_diagnostic_visible = {fg = fg_visible, bg = bg_visible, bold = false, italic = false}
  hl.error_selected = {fg = fg_error, bg = bg_selected, bold = false, italic = false}
  hl.error_visible = {fg = fg_visible, bg = bg_visible, bold = false, italic = false}
  hl.fill = {bg = bg_fill, bold = false, italic = false}
  hl.hint = {fg = fg_inactive, bg = bg_inactive, bold = false, italic = false}
  hl.hint_diagnostic = {fg = fg_inactive, bg = bg_inactive, bold = false, italic = false}
  hl.hint_diagnostic_selected = {fg = fg_hint, bg = bg_selected, bold = false, italic = false}
  hl.hint_diagnostic_visible = {fg = fg_visible, bg = bg_visible, bold = false, italic = false}
  hl.hint_selected = {fg = fg_hint, bg = bg_selected, bold = false, italic = false}
  hl.hint_visible = {fg = fg_visible, bg = bg_visible, bold = false, italic = false}
  hl.info = {fg = fg_inactive, bg = bg_inactive, bold = false, italic = false}
  hl.info_diagnostic = {fg = fg_inactive, bg = bg_inactive, bold = false, italic = false}
  hl.info_diagnostic_selected = {fg = fg_info, bg = bg_selected, bold = false, italic = false}
  hl.info_diagnostic_visible = {fg = fg_visible, bg = bg_visible, bold = false, italic = false}
  hl.info_selected = {fg = fg_info, bg = bg_selected, bold = false, italic = false}
  hl.info_visible = {fg = fg_visible, bg = bg_visible, bold = false, italic = false}
  hl.modified = {fg = fg_inactive, bg = bg_inactive, bold = false, italic = false}
  hl.modified_selected = {fg = fg_selected, bg = bg_selected, bold = false, italic = false}
  hl.modified_visible = {fg = fg_visible, bg = bg_visible, bold = false, italic = false}
  hl.pick = {bg = bg_inactive, bold = false, italic = false}
  hl.pick_selected = {bg = bg_selected, bold = false, italic = false}
  hl.pick_visible = {bg = bg_visible, bold = false, italic = false}
  hl.separator = {fg = bg_fill, bg = bg_inactive, bold = false, italic = false}
  hl.separator_selected = {fg = bg_fill, bg = bg_selected, bold = false, italic = false}
  hl.separator_visible = {fg = bg_fill, bg = bg_visible, bold = false, italic = false}
  hl.tab = {fg = fg_inactive, bg = bg_inactive, bold = false, italic = false}
  hl.tab_close = {bg = bg_fill, bold = false, italic = false}
  hl.tab_selected = {fg = fg_selected, bg = bg_selected, bold = false, italic = false}
  hl.warning = {fg = fg_inactive, bg = bg_inactive, bold = false, italic = false}
  hl.warning_diagnostic = {fg = fg_inactive, bg = bg_inactive, bold = false, italic = false}
  hl.warning_diagnostic_selected = {fg = fg_warning, bg = bg_selected, bold = false, italic = false}
  hl.warning_diagnostic_visible = {fg = fg_visible, bg = bg_visible, bold = false, italic = false}
  hl.warning_selected = {fg = fg_warning, bg = bg_selected, bold = false, italic = false}
  hl.warning_visible = {fg = fg_visible, bg = bg_visible, bold = false, italic = false}
end

require('bufferline').setup {
  options = {
    always_show_bufferline = false,
    close_command = 'Bdelete! %d',
    right_mouse_command = 'Bdelete! %d',
    diagnostics = 'nvim_lsp',
    diagnostics_update_in_insert = false,
    diagnostics_indicator = function(_, _, diagnostics_dict, _)
      local s = ' '
      for e, n in pairs(diagnostics_dict) do
        local sym = e == 'error' and '' or (e == 'warning' and '' or (e == 'info' and '' or '') )
        s = s .. (#s > 1 and ' ' or '') .. sym .. ' ' .. n
      end
      return s
    end,
    offsets = {
      {
        filetype = 'NvimTree',
        text = 'File Explorer',
        text_align = 'center'
      },
      {
        filetype = 'undotree',
        text = 'Undotree',
        text_align = 'center'
      }
    },
    indicator = {
      icon = ' '
    },
    show_close_icon = false
  },
  highlights = hl
}
