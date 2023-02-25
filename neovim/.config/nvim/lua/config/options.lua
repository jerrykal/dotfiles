-- Map leaderoptions
vim.g.mapleader = " "

local fn = vim.fn
local opt = vim.opt

-- General options
opt.completeopt = { "menu", "menuone", "noselect" }
opt.formatoptions = "jroqln"
opt.guicursor:append("a:Cursor/lCursor")
opt.lazyredraw = true
opt.list = true
opt.listchars = { extends = "›", precedes = "‹" }
opt.mouse = "a"
opt.mousemoveevent = true
opt.number = true
opt.pumblend = 10
opt.pumheight = 10
opt.relativenumber = true
opt.scrolloff = 1
opt.sessionoptions = "buffers,curdir,folds,winpos,winsize"
opt.shortmess:append("I")
opt.sidescrolloff = 5
opt.signcolumn = "yes:1"
opt.splitbelow = true
opt.splitright = true
opt.termguicolors = true
opt.textwidth = 80
opt.timeoutlen = 300
opt.updatetime = 250
opt.winblend = 10
opt.wrap = false

-- Indentation options
opt.expandtab = true
opt.shiftround = true
opt.shiftwidth = 4
opt.smartindent = true
opt.tabstop = 4

-- Search options
opt.ignorecase = true
opt.smartcase = true

-- Enable persistent undo
if fn.has("persistent_undo") then
  opt.undodir = fn.expand(fn.stdpath("data") .. "/undo")
  opt.undofile = true
end

-- Statusline
opt.laststatus = 3
opt.statusline = "%!v:lua.require('config.statusline').setup()"

-- Python provider
vim.g.python3_host_prog = "$PYENV_ROOT/versions/pynvim/bin/python3"
