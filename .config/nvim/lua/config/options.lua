-- Map leader key
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local opt = vim.opt

-- General options
opt.completeopt = { "menu", "menuone", "noselect" }
opt.confirm = true
opt.fillchars = { foldopen = "", foldclose = "", fold = " ", foldsep = " ", diff = "╱", eob = " " }
opt.guicursor =
  "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50,a:blinkwait700-blinkoff400-blinkon250,sm:block-blinkwait175-blinkoff150-blinkon175"
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣", extends = "…", precedes = "‹" }
opt.mouse = "a"
opt.mousemoveevent = true
opt.number = true
opt.pumblend = 10
opt.pumheight = 10
opt.relativenumber = true
opt.scrolloff = 8
opt.sessionoptions = "blank,buffers,curdir,folds,globals,help,localoptions,skiprtp,tabpages,terminal,winpos,winsize"
opt.shortmess:append("I")
opt.sidescrolloff = 8
opt.signcolumn = "yes:1"
opt.splitbelow = true
opt.splitkeep = "screen"
opt.splitright = true
opt.statusline = [[%!v:lua.require("util.statusline").statusline()]]
opt.termguicolors = true
opt.timeoutlen = 300
opt.undofile = true
opt.undolevels = 10000
opt.updatetime = 200
opt.updatetime = 250
opt.virtualedit = "block"
opt.wrap = false

-- Search options
opt.ignorecase = true
opt.smartcase = true

-- Indentation options
opt.expandtab = true
opt.shiftround = true
opt.shiftwidth = 2
opt.smartindent = true
opt.tabstop = 2

-- Folding options
opt.foldcolumn = "1"
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldenable = true

-- Per project Global Marks
opt.exrc = true
opt.secure = true
local workspace_path = vim.fn.getcwd()
local cache_dir = vim.fn.stdpath("data")
local unique_id = vim.fn.fnamemodify(workspace_path, ":t") .. "_" .. vim.fn.sha256(workspace_path):sub(1, 8) ---@type string
local shadafile = cache_dir .. "/myshada/" .. unique_id .. ".shada"

opt.shadafile = shadafile
