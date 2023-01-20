-- Map leader
vim.g.mapleader = " "

-- Helpers
local fn = vim.fn
local opt = vim.opt

-- General options
opt.completeopt = { "menu", "menuone", "noselect" }
opt.formatoptions = "jcroqlnt"
opt.guicursor:append("a:Cursor/lCursor")
opt.lazyredraw = true
opt.list = true
opt.listchars = { extends = "›", precedes = "‹" }
opt.mouse = "a"
opt.mousemoveevent = true
opt.number = true
opt.pumheight = 12
opt.relativenumber = true
opt.scrolloff = 1
opt.sessionoptions = "buffers,curdir,folds,winpos,winsize,help"
opt.shortmess:append("I")
opt.sidescrolloff = 5
opt.signcolumn = "yes"
opt.splitbelow = true
opt.splitright = true
opt.termguicolors = true
opt.textwidth = 80
opt.timeoutlen = 300
opt.updatetime = 250
opt.wrap = false

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
  local target_path = fn.stdpath("data") .. "/undo"
  if not fn.isdirectory(target_path) then
    fn.mkdir(target_path, "p", 0700)
  end

  opt.undodir = target_path
  opt.undofile = true
end

-- Statusline
opt.laststatus = 3
opt.statusline = "%!v:lua.require('config.statusline').setup()"
