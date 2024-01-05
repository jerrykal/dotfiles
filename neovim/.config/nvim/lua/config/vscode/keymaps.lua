local map = vim.keymap.set

-- Allow moving the cursor through wrapped lines with j, k
map("", "j", 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', { expr = true })
map("", "k", 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', { expr = true })

-- Use ESC to turn off search highlighting
map("n", "<esc>", ":noh<cr>")

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

-- Let vscode handle undo/redo
map({ "n", "x" }, "u", function()
  vscode.call("runCommands", {
    args = {
      commands = {
        "undo",
        "cancelSelection",
      },
    },
  })
end)
map({ "n", "x" }, "<C-r>", function()
  vscode.call("runCommands", {
    args = {
      commands = {
        "redo",
        "cancelSelection",
      },
    },
  })
end)

-- stylua: ignore start

-- Diagnostics
map("n", "[d", function() vscode.call("editor.action.marker.prev") end)
map("n", "]d", function() vscode.call("editor.action.marker.next") end)

-- stylua: ignore end
