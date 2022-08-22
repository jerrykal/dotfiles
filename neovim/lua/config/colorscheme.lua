vim.g.vscode_style = 'dark'
vim.cmd[[colorscheme vscode]]

-- some tweaks
local c = require('vscode.colors')
local hl = vim.api.nvim_set_hl
hl(0, 'Search', {fg = 'NONE', bg = '#613214'})
hl(0, 'TSStringEscape', {fg = c.vscYellowOrange, bg = 'NONE', bold = true})
hl(0, 'TSConstructor', {fg = c.vscYellow, bg = 'NONE'})
hl(0, 'IndentBlanklineContextChar', {fg = '#707070', bg = 'NONE', nocombine = true})
hl(0, 'IndentBlanklineChar', {fg = '#404040', bg = 'NONE', nocombine = true})
hl(0, 'IndentBlanklineSpaceChar', {fg = '#404040', bg = 'NONE', nocombine = true})
hl(0, 'IndentBlanklineSpaceCharBlankline', {fg = '#404040', bg = 'NONE', nocombine = true})

vim.cmd[[highlight clear CursorLine]]
vim.cmd[[highlight clear NvimTreeCursorLine]]
