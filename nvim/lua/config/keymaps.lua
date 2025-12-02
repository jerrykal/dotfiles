local map = vim.keymap.set

-- Allow moving the cursor through wrapped lines with j, k
map({ "n", "x" }, "j", 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', { expr = true, silent = true })
map({ "n", "x" }, "k", 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', { expr = true, silent = true })

-- Save file
map("n", "<C-s>", "<cmd>w<cr><esc>", { desc = "Save File" })
map("n", "<C-S-s>", "<cmd>noa w<cr><esc>", { desc = "Save File Without Formatting" })

-- New file
map("n", "<leader>fn", "<cmd>enew<cr>", { desc = "New File" })

-- Use ESC to turn off search highlighting
map("n", "<esc>", "<cmd>noh<cr>")

-- Add undo break-points
map("i", ",", ",<c-g>u")
map("i", ".", ".<c-g>u")
map("i", ";", ";<c-g>u")

-- Better indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Commenting
map("n", "gco", "o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Below" })
map("n", "gcO", "O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Above" })

-- Navigate modified(unsaved) buffers
map("n", "]=", "<cmd>execute +v:count1 . 'bmodified'<cr>", { desc = "Next Modified Buffer" })
map("n", "[=", "<cmd>execute -v:count1 . 'bmodified'<cr>", { desc = "Prev Modified Buffer" })

-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
map("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true })
map("x", "n", "'Nn'[v:searchforward]", { expr = true })
map("o", "n", "'Nn'[v:searchforward]", { expr = true })
map("n", "N", "'nN'[v:searchforward].'zv'", { expr = true })
map("x", "N", "'nN'[v:searchforward]", { expr = true })
map("o", "N", "'nN'[v:searchforward]", { expr = true })

-- Diagnostic
local diagnostic_goto = function(next, severity)
  return function()
    vim.diagnostic.jump({
      count = (next and 1 or -1) * vim.v.count1,
      severity = severity and vim.diagnostic.severity[severity] or nil,
      float = true,
    })
  end
end
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
map("n", "]d", diagnostic_goto(true), { desc = "Next Diagnostic" })
map("n", "[d", diagnostic_goto(false), { desc = "Prev Diagnostic" })
map("n", "]e", diagnostic_goto(true, "ERROR"), { desc = "Next Error" })
map("n", "[e", diagnostic_goto(false, "ERROR"), { desc = "Prev Error" })
map("n", "]w", diagnostic_goto(true, "WARN"), { desc = "Next Warning" })
map("n", "[w", diagnostic_goto(false, "WARN"), { desc = "Prev Warning" })

-- Lazy
map("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy" })

-- Tabs
map("n", "<leader><tab>l", "<cmd>tablast<cr>", { desc = "Last Tab" })
map("n", "<leader><tab>o", "<cmd>tabonly<cr>", { desc = "Close Other Tabs" })
map("n", "<leader><tab>f", "<cmd>tabfirst<cr>", { desc = "First Tab" })
map("n", "<leader><tab><tab>", "<cmd>tabnew<cr>", { desc = "New Tab" })
map("n", "<leader><tab>]", "<cmd>tabnext<cr>", { desc = "Next Tab" })
map("n", "<leader><tab>d", "<cmd>tabclose<cr>", { desc = "Close Tab" })
map("n", "<leader><tab>[", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })

-- Tmux
vim.keymap.set(
  "n",
  "<leader>to",
  require("config.utils").open_in_new_tmux_window,
  { desc = "Open current file in new Tmux window" }
)
