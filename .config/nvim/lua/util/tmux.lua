local M = {}

function M.open_buf_in_new_tmux_window()
  if vim.env.TMUX == nil then
    vim.notify("Not running inside a Tmux session.", vim.log.levels.ERROR)
    return
  end

  -- Retrieve file informations
  local filepath = vim.fn.expand("%:p")
  local filedir = vim.fn.expand("%:p:h")
  if filepath == "" then
    vim.notify("Buffer has no file path.", vim.log.levels.WARN)
    return
  end

  -- Save the file
  if vim.bo.modified then
    vim.cmd("write")
  end

  -- Create a new Tmux window and get its ID
  -- -P prints the window ID (e.g., @1) so we can target it.
  -- This creates a window running the default shell in the file's directory.
  local create_cmd = string.format("tmux new-window -c %s -P", vim.fn.shellescape(filedir))
  local window_id = vim.fn.system(create_cmd)
  window_id = string.gsub(window_id, "%s+", "")

  -- Send the nvim command to the new window
  -- 'send-keys' types the command into the shell we just created.
  -- This ensures that when nvim exits, you drop back to that shell.
  local run_cmd = "nvim " .. vim.fn.shellescape(filepath)
  local send_keys_cmd = string.format("tmux send-keys -t %s %s C-m", window_id, vim.fn.shellescape(run_cmd))
  vim.fn.system(send_keys_cmd)
end

return M
