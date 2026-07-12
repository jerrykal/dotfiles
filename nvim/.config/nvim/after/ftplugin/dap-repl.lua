-- In prompt buffers <C-w> is a window-command prefix (:h prompt-buffer);
-- remap to <C-S-w>, which core treats as delete-word there.
vim.keymap.set("i", "<C-w>", "<C-S-w>", { buffer = true })

vim.keymap.set("i", "<C-p>", require("dap.repl").on_up, { buffer = true })
vim.keymap.set("i", "<C-n>", require("dap.repl").on_down, { buffer = true })

-- Readline-style <C-a>/<C-e>; <C-a> lands after the prompt, not col 0.
vim.keymap.set("i", "<C-a>", function()
  local row = vim.api.nvim_win_get_cursor(0)[1]
  vim.api.nvim_win_set_cursor(0, { row, #vim.fn.prompt_getprompt(0) })
end, { buffer = true })
vim.keymap.set("i", "<C-e>", "<End>", { buffer = true })
