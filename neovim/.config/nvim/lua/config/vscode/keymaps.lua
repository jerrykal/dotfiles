local map = vim.keymap.set

-- Allow moving the cursor through wrapped lines with j, k
map("", "j", 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', { expr = true })
map("", "k", 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', { expr = true })

-- Use ESC to turn off search highlighting
map("n", "<esc>", "<cmd>noh<cr>")

-- System clipboard copy/paste
map("n", "<leader>y", '"+y')
map("n", "<leader>Y", '"+Y')
map("n", "<leader>p", '"+p')
map("n", "<leader>P", '"+P')
map("v", "<leader>y", '"+y')
map("v", "<leader>p", '"+p')
map("v", "<leader>P", '"+P')

-- Better indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
map({ "n", "x" }, "n", "'Nn'[v:searchforward]", { expr = true })
map({ "n", "x" }, "N", "'nN'[v:searchforward]", { expr = true })

-- VSCode API
local vscode = require("vscode-neovim")

-- -- Let vscode handle undo/redo
-- map({ "n", "x" }, "u", function()
--   vscode.call("runCommands", {
--     args = {
--       commands = {
--         "undo",
--         "cancelSelection",
--       },
--     },
--   })
-- end)
-- map({ "n", "x" }, "<C-r>", function()
--   vscode.call("runCommands", {
--     args = {
--       commands = {
--         "redo",
--         "cancelSelection",
--       },
--     },
--   })
-- end)

-- stylua: ignore start

-- Diagnostics
map("n", "[d", function() vscode.call("editor.action.marker.prev") end)
map("n", "]d", function() vscode.call("editor.action.marker.next") end)

-- Git
map("n", "]h", function() vscode.call("workbench.action.editor.nextChange") end)
map("n", "[h", function() vscode.call("workbench.action.editor.previousChange") end)
map({"x"}, "<leader>hs", function() vscode.call("git.stageSelectedRanges") end)
map({"x"}, "<leader>hu", function() vscode.call("git.unstageSelectedRanges") end)
map({"x"}, "<leader>hr", function() vscode.call("git.revertSelectedRanges") end)
map("n", "<leader>hp", function() vscode.call("editor.action.dirtydiff.next") end)

-- Window management
map("n", "<C-w>z", function() vscode.call("workbench.action.toggleMaximizeEditorGroup") end)

-- LSP
map("n", "<leader>rn", function() vscode.call("editor.action.rename") end)

-- Code Spell Checker
map({"n", "x"}, "zg", function () vscode.call("cSpell.addWordToUserDictionary") end)
map({"n", "x"}, "zw", function () vscode.call("cSpell.removeWordFromUserDictionary") end)

-- stylua: ignore end
