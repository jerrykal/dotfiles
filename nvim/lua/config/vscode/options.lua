-- Map leader key
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local opt = vim.opt

-- Search options
opt.ignorecase = true
opt.smartcase = true

-- Treat .json files as jsonc
vim.filetype.add({ extension = { json = "jsonc" } })
