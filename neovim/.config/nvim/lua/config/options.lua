-- Map leader key
vim.g.mapleader = " "

local fn = vim.fn
local opt = vim.opt

-- General options
opt.completeopt = { "menu", "menuone", "noselect" } -- Completion options
opt.confirm = true -- Confirm before closing unsaved buffers
opt.cursorline = true
opt.guicursor:append("a:Cursor/lCursor") -- Set cursor shape
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "·", extends = "›", precedes = "‹" }
opt.mouse = "a" -- Enable mouse support
opt.mousemoveevent = true
opt.number = true
opt.pumblend = 10 -- Popup menu transparency
opt.pumheight = 10 -- Max height of popup menu
opt.relativenumber = true
opt.scrolloff = 4
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }
opt.shortmess:append("I") -- Disable intro message
opt.sidescrolloff = 8
opt.signcolumn = "yes:1"
opt.spell = true
opt.splitbelow = true -- Open new windows to the bottom
opt.splitkeep = "screen"
opt.splitright = true -- Open new windows to the right
opt.termguicolors = true -- Enable true colors
opt.textwidth = 80
opt.timeoutlen = 300
opt.updatetime = 250
opt.virtualedit = "block" -- Allow cursor to move anywhere in visual block mode
opt.winblend = 10 -- Window transparency
opt.wrap = false -- Disable line wrapping

-- Indentation options
opt.expandtab = true
opt.shiftround = true
opt.shiftwidth = 2
opt.smartindent = true
opt.tabstop = 2

-- Search options
opt.ignorecase = true
opt.smartcase = true

-- Enable persistent undo
if fn.has("persistent_undo") then
  opt.undodir = fn.expand(fn.stdpath("data") .. "/undo")
  opt.undofile = true
end

-- Statusline
opt.laststatus = 3 -- Always show statusline
opt.statusline = "%!v:lua.require('config.statusline').setup()"

-- TODO: Fold
if fn.has("nvim-0.9.0") == 1 then
  -- vim.opt.statuscolumn = [[%!v:lua.require'lazyvim.util'.ui.statuscolumn()]]
end

-- Python provider
vim.g.python3_host_prog = "$PYENV_ROOT/versions/pynvim/bin/python3"
