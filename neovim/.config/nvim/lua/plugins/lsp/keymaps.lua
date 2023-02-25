local M = {}

function M.setup(_, buffer)
  local bufopts = { noremap = true, silent = true, buffer = buffer }

  vim.keymap.set("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostic" }, bufopts)
  vim.keymap.set("n", "[d", M.diagnostic_goto(true), { desc = "Next Diagnostic" }, bufopts)
  vim.keymap.set("n", "]d", M.diagnostic_goto(false), { desc = "Prev Diagnostic" }, bufopts)
  vim.keymap.set("n", "[e", M.diagnostic_goto(true, "ERROR"), { desc = "Next Error" }, bufopts)
  vim.keymap.set("n", "]e", M.diagnostic_goto(false, "ERROR"), { desc = "Prev Error" }, bufopts)
  vim.keymap.set("n", "[w", M.diagnostic_goto(true, "WARNING"), { desc = "Next Warning" }, bufopts)
  vim.keymap.set("n", "]w", M.diagnostic_goto(false, "WARNING"), { desc = "Prev Warning" }, bufopts)

  vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Goto Declaration" }, bufopts)
  vim.keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<cr>", { desc = "Goto Definition" }, bufopts)
  vim.keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<cr>", { desc = "Goto Implementation" }, bufopts)
  vim.keymap.set("n", "gr", "<cmd>Telescope lsp_references<cr>", { desc = "Goto Reference" }, bufopts)
  vim.keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<cr>", { desc = "Goto Type Definition" }, bufopts)

  vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover" }, bufopts)
  vim.keymap.set("n", "gS", vim.lsp.buf.signature_help, { desc = "Signature Help" }, bufopts)
  vim.keymap.set("i", "<c-k>", vim.lsp.buf.signature_help, { desc = "Signature Help" }, bufopts)

  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename" }, bufopts)
  vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" }, bufopts)

  vim.keymap.set("n", "<leader>F", function()
    vim.lsp.buf.format({ async = true })
  end, { desc = "Format Document" }, bufopts)
  vim.keymap.set("v", "<leader>F", function()
    vim.lsp.buf.format({ async = true })
  end, { desc = "Format Range" }, bufopts)
end

function M.diagnostic_goto(next, severity)
  local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
  severity = severity and vim.diagnostic.severity[severity] or nil
  return function()
    go({ severity = severity })
  end
end

return M
