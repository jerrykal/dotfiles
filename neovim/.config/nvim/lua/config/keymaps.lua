local map = vim.keymap.set

-- Allow moving the cursor through wrapped lines with j, k
map("", "j", 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', { expr = true })
map("", "k", 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', { expr = true })

-- Use ESC to turn off search highlighting and dismiss notification messages
map("n", "<esc>", function()
  require("notify").dismiss()
  vim.cmd.noh()
end)

-- Press ESC twice to enter normal mode in terminal
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

-- Command mode mapping
map("c", "<c-a>", "<home>")
map("c", "<c-k>", "<up>")
map("c", "<c-j>", "<down>")
map("c", "<c-b>", "<left>")
map("c", "<c-f>", "<right>")

-- Tabs
map("n", "<leader><tab>n", "<cmd>tabnew<cr>", { desc = "New Tab" })
map("n", "<leader><tab>x", "<cmd>tabclose<cr>", { desc = "Close Tab" })
map("n", "<leader><tab>l", "<cmd>tabnext<cr>", { desc = "Next Tab" })
map("n", "<leader><tab>h", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })

-- Open in VSCode
map("n", "<leader>ox", function()
  local file = vim.fn.expand("%")
  local r, c = unpack(vim.api.nvim_win_get_cursor(0))
  if file == "" then
    vim.cmd("silent !code .")
  else
    vim.cmd("silent !code . && code -g " .. vim.fn.expand("%") .. ":" .. r .. ":" .. c)
  end
end, { desc = "[O]pen E[x]ternal editor" })

-- lazy
map("n", "<leader>l", "<cmd>:Lazy<cr>", { desc = "Lazy" })
