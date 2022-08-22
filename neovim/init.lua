vim.g.did_load_filetypes = 1
require 'impatient'

-- Helpers
local cmd = vim.cmd
local fn = vim.fn
local g = vim.g
local opt = vim.opt

-- General options
opt.colorcolumn = {81}
opt.completeopt = {'menu', 'menuone', 'noselect'}
opt.cursorline = true
opt.guicursor = opt.guicursor + 'a:blinkon1'
opt.lazyredraw = true
opt.mouse = 'a'
opt.number = true
opt.pumheight = 12
opt.relativenumber = true
opt.sessionoptions = opt.sessionoptions + 'globals'
opt.showmode = false
opt.signcolumn = 'yes'
opt.termguicolors = true
opt.textwidth=80
opt.timeoutlen = 500
opt.updatetime = 250

-- Indentation options
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2

-- Search options
opt.ignorecase = true
opt.smartcase = true

-- Enable persistent undo
if fn.has('persistent_undo') then
  local target_path = fn.stdpath('data') .. '/undo'
  if not fn.isdirectory(target_path) then
    fn.mkdir(target_path, 'p', 0700)
  end

  opt.undodir = target_path
  opt.undofile = true
end

-- Mappings
g.mapleader = ' '
require('mappings').misc()

-- Commands
cmd [[command! PackerClean lua require('plugins').clean()]]
cmd [[command! PackerCompile lua require('plugins').compile()]]
cmd [[command! PackerInstall lua require('plugins').install()]]
cmd [[command! PackerStatus lua require('plugins').status()]]
cmd [[command! PackerSync lua require('plugins').sync()]]
cmd [[command! PackerUpdate lua require('plugins').update()]]
