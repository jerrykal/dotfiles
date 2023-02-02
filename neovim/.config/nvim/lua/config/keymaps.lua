local map = vim.keymap.set

-- Allow moving the cursor through wrapped lines with j, k
map("", "j", 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', { expr = true })
map("", "k", 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', { expr = true })

-- Select all
map("n", "<C-a>", "ggVG")

-- Use esc to turn off search highlighting
map("n", "<esc>", vim.cmd.noh)

-- Press esc twice to enter normal mode in terminal
map("t", "<esc><esc>", "<C-\\><C-n>")

-- System clipboard copy/paste
map("n", "<leader>y", '"+y')
map("n", "<leader>Y", '"+Y')
map("n", "<leader>p", '"+p')
map("n", "<leader>P", '"+P')
map("v", "<leader>y", '"+y')
map("v", "<leader>p", '"+p')
map("v", "<leader>P", '"+P')

-- Add undo break-points
map("i", ",", ",<c-g>u")
map("i", ".", ".<c-g>u")
map("i", ";", ";<c-g>u")

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

-- lazy
map("n", "<leader>l", "<cmd>:Lazy<cr>", { desc = "Lazy" })

-- new file
map("n", "<c-n>", "<cmd>enew<cr>", { desc = "New File" })

-- Trouble
map("n", "<leader>tt", "<cmd>TroubleToggle<cr>", { desc = "Toggle Trouble" }, { silent = true, noremap = true })
map("n", "<leader>tw", "<cmd>TroubleToggle workspace_diagnostics<cr>", { desc = "Workspace Diagnostic (Trouble)" }, { silent = true, noremap = true })
map("n", "<leader>td", "<cmd>TroubleToggle document_diagnostics<cr>", { desc = "Document Diagnostic (Trouble)" }, { silent = true, noremap = true })
map("n", "<leader>tl", "<cmd>TroubleToggle loclist<cr>", { desc = "Location List (Trouble)" }, { silent = true, noremap = true })
map("n", "<leader>tq", "<cmd>TroubleToggle quickfix<cr>", { desc = "Quickfix List (Trouble)" }, { silent = true, noremap = true })
map("n", "gR", "<cmd>TroubleToggle lsp_references<cr>", { desc = "Lsp References (Trouble)" }, { silent = true, noremap = true })

-- Goto Preview
map("n", "gpd", "<cmd>lua require('goto-preview').goto_preview_definition<cr>", { desc = "Preview Definition" }, {noremap = true})
map("n", "gpt", "<cmd>lua require('goto-preview').goto_preview_type_definition<cr>", { desc = "Preview Type Definition" }, {noremap = true})
map("n", "gpi", "<cmd>lua require('goto-preview').goto_preview_implementation<cr>", { desc = "Preview Implementation" }, {noremap = true})
map("n", "gpr", "<cmd>lua require('goto-preview').goto_preview_references<cr>", { desc = "Preview References" }, {noremap = true})
map("n", "gP", "<cmd>lua require('goto-preview').close_all_win<cr>", { desc = "Close All Preview Windows" }, {noremap = true})

-- BBye
map("n", "x", "<cmd>Bdelete<cr>", { silent = true })
map("n", "X", "<cmd>Bdelete!<cr>", { silent = true })

-- Bufferline
map("n", "\\", "<cmd>BufferLinePick<cr>", { silent = true })
map("n", "|", "<cmd>BufferLinePickClose<cr>", { silent = true })
map("n", "<s-l>", "<cmd>BufferLineCycleNext<cr>", { silent = true })
map("n", "<s-h>", "<cmd>BufferLineCyclePrev<cr>", { silent = true })
map("n", "<a-l>", "<cmd>BufferLineMoveNext<cr>", { silent = true })
map("n", "<a-h>", "<cmd>BufferLineMovePrev<cr>", { silent = true })
map("n", "<leader>1", "<cmd>BufferLineGoToBuffer 1<cr>", { desc = "Goto Buffer 1" }, { silent = true })
map("n", "<leader>2", "<cmd>BufferLineGoToBuffer 2<cr>", { desc = "Goto Buffer 2" }, { silent = true })
map("n", "<leader>3", "<cmd>BufferLineGoToBuffer 3<cr>", { desc = "Goto Buffer 3" }, { silent = true })
map("n", "<leader>4", "<cmd>BufferLineGoToBuffer 4<cr>", { desc = "Goto Buffer 4" }, { silent = true })
map("n", "<leader>5", "<cmd>BufferLineGoToBuffer 5<cr>", { desc = "Goto Buffer 5" }, { silent = true })
map("n", "<leader>6", "<cmd>BufferLineGoToBuffer 6<cr>", { desc = "Goto Buffer 6" }, { silent = true })
map("n", "<leader>7", "<cmd>BufferLineGoToBuffer 7<cr>", { desc = "Goto Buffer 7" }, { silent = true })
map("n", "<leader>8", "<cmd>BufferLineGoToBuffer 8<cr>", { desc = "Goto Buffer 8" }, { silent = true })
map("n", "<leader>9", "<cmd>BufferLineGoToBuffer 9<cr>", { desc = "Goto Buffer 9" }, { silent = true })
map("n", "<leader>0", "<cmd>BufferLineGoToBuffer -1<cr>", { desc = "Goto Last Buffer" }, { silent = true })

-- Telescope
map("n", "<leader><space>", "<cmd>Telescope find_files no_ignore=true hidden=true<cr>", { desc = "Find Files" })
map("n", "<leader>/", "<cmd>Telescope live_grep<cr>", { desc = "Find in Files (Grep)" })
map("n", "<leader>:", "<cmd>Telescope command_history<cr>", { desc = "Show Command History" })
map("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Buffers" })
map("n", "<leader>ff", "<cmd>Telescope find_files no_ignore=true hidden=true<cr>", { desc = "Files" })
map("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc =  "Help Pages" })
map("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Old Files" })

-- Neotree
map("n", "<leader>e", "<cmd>Neotree toggle<cr>", { desc = "Toggle Neotree" })

-- Windows.nvim
map("n", "<C-w>z", "<cmd>WindowsMaximize<cr>", { desc = "Maximize Current Window" })
map("n", "<C-w>_", "<cmd>WindowsMaximizeVertically<cr>", { desc = "Maximize Current Window Vertically" })
map("n", "<C-w>|", "<cmd>WindowsMaximizeHorizontally<cr>", { desc = "Maximize Current Window Horizontally" })
map('n', '<C-w>=', '<cmd>WindowsEqualize<cr>', { desc = "Equalize Windows" })