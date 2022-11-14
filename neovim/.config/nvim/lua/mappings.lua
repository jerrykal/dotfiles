local map = vim.keymap.set

-- Map leader
vim.g.mapleader = " "

-- Allow moving the cursor through wrapped lines with j, k
map("", "j", 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', { expr = true })
map("", "k", 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', { expr = true })

-- Select all
map("n", "<C-a>", "ggVG")

-- Use Esc to turn off search highlighting
map("n", "<Esc>", ":noh<CR>")

-- Press Esc twice to enter normal mode in terminal
map("t", "<Esc><Esc>", "<C-\\><C-n>")

-- System clipboard copy/paste
map("n", "<leader>y", '"+y')
map("n", "<leader>Y", '"+Y')
map("n", "<leader>p", '"+p')
map("n", "<leader>P", '"+P')
map("v", "<leader>y", '"+y')
map("v", "<leader>p", '"+p')
map("v", "<leader>P", '"+P')

-- Window navigation
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

-- Save file
map("i", "<C-s>", "<cmd>:w<cr>")
map("n", "<C-s>", "<cmd>:w<cr><esc>")

-- Better indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
map("n", "n", "'Nn'[v:searchforward]", { expr = true })
map("x", "n", "'Nn'[v:searchforward]", { expr = true })
map("o", "n", "'Nn'[v:searchforward]", { expr = true })
map("n", "N", "'nN'[v:searchforward]", { expr = true })
map("x", "N", "'nN'[v:searchforward]", { expr = true })
map("o", "N", "'nN'[v:searchforward]", { expr = true })

-- Trouble
map("n", "<leader>tt", "<cmd>TroubleToggle<cr>", { silent = true, noremap = true })
map("n", "<leader>tw", "<cmd>TroubleToggle workspace_diagnostics<cr>", { silent = true, noremap = true })
map("n", "<leader>td", "<cmd>TroubleToggle document_diagnostics<cr>", { silent = true, noremap = true })
map("n", "<leader>tl", "<cmd>TroubleToggle loclist<cr>", { silent = true, noremap = true })
map("n", "<leader>tq", "<cmd>TroubleToggle quickfix<cr>", { silent = true, noremap = true })
map("n", "gR", "<cmd>TroubleToggle lsp_references<cr>", { silent = true, noremap = true })

-- BBye
map("n", "<leader>x", "<cmd>Bdelete<CR>", { silent = true })
map("n", "<leader>X", "<cmd>Bdelete!<CR>", { silent = true })

-- Bufferline
map("n", "\\", "<cmd>BufferLinePick<CR>", { silent = true })
map("n", "|", "<cmd>BufferLinePickClose<CR>", { silent = true })
map("n", "<leader>]", "<cmd>BufferLineCycleNext<CR>", { silent = true })
map("n", "<leader>[", "<cmd>BufferLineCyclePrev<CR>", { silent = true })
map("n", "<leader>1", "<cmd>BufferLineGoToBuffer 1<CR>", { silent = true })
map("n", "<leader>2", "<cmd>BufferLineGoToBuffer 2<CR>", { silent = true })
map("n", "<leader>3", "<cmd>BufferLineGoToBuffer 3<CR>", { silent = true })
map("n", "<leader>4", "<cmd>BufferLineGoToBuffer 4<CR>", { silent = true })
map("n", "<leader>5", "<cmd>BufferLineGoToBuffer 5<CR>", { silent = true })
map("n", "<leader>6", "<cmd>BufferLineGoToBuffer 6<CR>", { silent = true })
map("n", "<leader>7", "<cmd>BufferLineGoToBuffer 7<CR>", { silent = true })
map("n", "<leader>8", "<cmd>BufferLineGoToBuffer 8<CR>", { silent = true })
map("n", "<leader>9", "<cmd>BufferLineGoToBuffer 9<CR>", { silent = true })
map("n", "<leader>0", "<cmd>BufferLineGoToBuffer -1<CR>", { silent = true })

-- Telescope
map("n", "<leader>fb", "<cmd>Telescope buffers<CR>")
map("n", "<leader>ff", "<cmd>Telescope find_files no_ignore=true hidden=true<CR>")
map("n", "<leader>fg", "<cmd>Telescope live_grep<CR>")
map("n", "<leader>fh", "<cmd>Telescope help_tags<CR>")
map("n", "<leader>fr", "<cmd>Telescope oldfiles<CR>")

-- NvimTree
map("n", "<C-n>", "<cmd>NvimTreeToggle<CR>")
