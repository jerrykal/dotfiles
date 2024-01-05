-- Map leader key
vim.g.mapleader = " "

local opt = vim.opt

-- Search options
opt.ignorecase = true
opt.smartcase = true
opt.scrolloff = 4

-- Python provider
vim.g.python3_host_prog = "$PYENV_ROOT/versions/pynvim/bin/python3"
