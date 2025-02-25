local map = vim.keymap.set

-- Allow moving the cursor through wrapped lines with j, k
-- map({ "n", "x" }, "j", function()
--   if vim.v.count == 0 then
--     return "<Cmd>call VSCodeNotify('cursorMove', { 'to': 'down', 'by': 'wrappedLine', 'value': v:count1 })<CR>"
--   else
--     return "j"
--   end
-- end, { expr = true, silent = true })
-- map({ "n", "x" }, "k", function()
--   if vim.v.count == 0 then
--     return "<Cmd>call VSCodeNotify('cursorMove', { 'to': 'up', 'by': 'wrappedLine', 'value': v:count1 })<CR>"
--   else
--     return "k"
--   end
-- end, { expr = true, silent = true })

-- Use ESC to turn off search highlighting
map({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>")

-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
map("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true })
map("x", "n", "'Nn'[v:searchforward]", { expr = true })
map("o", "n", "'Nn'[v:searchforward]", { expr = true })
map("n", "N", "'nN'[v:searchforward].'zv'", { expr = true })
map("x", "N", "'nN'[v:searchforward]", { expr = true })
map("o", "N", "'nN'[v:searchforward]", { expr = true })

-- Better indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

-- VSCode API
local vscode = require("vscode-neovim")

-- stylua: ignore start

-- Let vscode handle undo/redo
map({ "n", "x" }, "u", function() vscode.call("undo") end)
map({ "n", "x" }, "<C-r>", function() vscode.call("redo") end)

-- Diagnostics
map("n", "[d", function() vscode.call("editor.action.marker.prev") end)
map("n", "]d", function() vscode.call("editor.action.marker.next") end)

-- Git
map("n", "]h", function() vscode.call("workbench.action.editor.nextChange") end)
map("n", "[h", function() vscode.call("workbench.action.editor.previousChange") end)
map("x", "<leader>hs", function() vscode.call("git.stageSelectedRanges") end)
map("x", "<leader>hu", function() vscode.call("git.unstageSelectedRanges") end)
map("x", "<leader>hr", function() vscode.call("git.revertSelectedRanges") end)
map("n", "<leader>hp", function() vscode.call("editor.action.dirtydiff.next") end)

-- Window management
map("n", "<C-w>z", function() vscode.call("workbench.action.toggleMaximizeEditorGroup") end)

-- LSP
map("n", "<leader>rn", function() vscode.call("editor.action.rename") end)

-- stylua: ignore end
