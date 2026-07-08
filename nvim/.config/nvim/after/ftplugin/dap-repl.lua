-- In prompt buffers <C-w> is a window-command prefix (:h prompt-buffer);
-- remap to <C-S-w>, which core treats as delete-word there.
vim.keymap.set("i", "<C-w>", "<C-S-w>", { buffer = true })
