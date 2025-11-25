-- Map leader key
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local opt = vim.opt

-- General options
opt.cursorline = true -- Highlight current line
opt.completeopt = { "menu", "menuone", "noselect" } -- Completion options
opt.confirm = true -- Confirm before closing unsaved buffers
opt.guicursor =
  "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50,a:blinkwait700-blinkoff400-blinkon250,sm:block-blinkwait175-blinkoff150-blinkon175"
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "·", extends = "›", precedes = "‹" }
opt.mouse = "a" -- Enable mouse support
opt.mousemoveevent = true
opt.number = true
opt.relativenumber = true
opt.pumblend = 10 -- Popup menu transparency
opt.pumheight = 10 -- Max height of popup menu
opt.scrolloff = 4
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }
opt.shortmess:append("I") -- Disable intro message
opt.sidescrolloff = 8
opt.signcolumn = "yes:1"
opt.colorcolumn = "120"
opt.splitbelow = true -- Open new windows to the bottom
opt.splitkeep = "screen"
opt.splitright = true -- Open new windows to the right
opt.termguicolors = true -- Enable true colors
opt.textwidth = 120
opt.timeoutlen = 300
opt.updatetime = 250
opt.virtualedit = "block" -- Allow cursor to move anywhere in visual block mode
opt.winblend = 10 -- Window transparency
opt.wrap = true -- Line wrapping
opt.undofile = true -- Persistent undo
opt.undolevels = 10000
opt.updatetime = 200 -- Save swap file and trigger CursorHold
opt.laststatus = 3 -- Global statueline
opt.statusline = [[%!v:lua.require("configs.statusline").statusline()]]

-- Search options
opt.ignorecase = true
opt.smartcase = true

-- Indentation options
opt.expandtab = true
opt.shiftround = true
opt.shiftwidth = 2
opt.smartindent = true
opt.tabstop = 2
