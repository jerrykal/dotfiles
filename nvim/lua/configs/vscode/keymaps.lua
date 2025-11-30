local map = vim.keymap.set

-- Use ESC to turn off search highlighting & redraw the screen
map({ "i", "n" }, "<esc>", "<cmd>noh | mode<cr><esc>")

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
map({"n"}, "u", function() vscode.call("undo") end)
map({"n"}, "<C-r>", function() vscode.call("redo") end)

-- Diagnostics
map("n", "[d", function() vscode.call("editor.action.marker.prev") end)
map("n", "]d", function() vscode.call("editor.action.marker.next") end)
map("n", "[e", function() vscode.call("next-error.prev.error") end)
map("n", "]e", function() vscode.call("next-error.next.error") end)
map("n", "[w", function() vscode.call("next-error.prev.warning") end)
map("n", "]w", function() vscode.call("next-error.next.warning") end)

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

-- Debugger
map("n", "<leader>db", function() vscode.call("editor.debug.action.toggleBreakpoint") end)
map("n", "<leader>dB", function() vscode.call("editor.debug.action.conditionalBreakpoint") end)
map("n", "<leader>di", function() vscode.call("editor.debug.action.toggleInlineBreakpoint") end)
map("n", "<leader>ds", function() vscode.call("workbench.action.debug.start") end)
map("n", "<leader>dc", function() vscode.call("workbench.action.debug.continue") end)
-- TODO

-- stylua: ignore end
