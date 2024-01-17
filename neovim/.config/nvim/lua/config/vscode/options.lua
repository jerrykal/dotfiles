-- Map leader key
vim.g.mapleader = " "

local opt = vim.opt

-- Search options
opt.ignorecase = true
opt.smartcase = true

-- Python provider
vim.g.python3_host_prog = "$PYENV_ROOT/versions/pynvim/bin/python3"
