local autocmd = vim.api.nvim_create_autocmd
local function augroup(name)
  return vim.api.nvim_create_augroup(name, { clear = true })
end

-- Refresh statusline on event
autocmd("DiagnosticChanged", {
  group = augroup("refresh_statusline"),
  callback = function()
    vim.cmd("redrawstatus")
  end,
})

-- Automatically toggle relativenumber
local toggle_relativenumber_augroup = augroup("toggle_relativenumber")
autocmd({ "BufEnter", "FocusGained", "WinEnter", "CmdlineLeave" }, {
  group = toggle_relativenumber_augroup,
  pattern = "*",
  callback = function()
    if vim.o.number then
      vim.o.relativenumber = true
      vim.cmd("redraw")
    end
  end,
})
autocmd({ "BufLeave", "FocusLost", "WinLeave", "CmdlineEnter" }, {
  group = toggle_relativenumber_augroup,
  pattern = "*",
  callback = function()
    if vim.o.number then
      vim.o.relativenumber = false
      vim.cmd("redraw")
    end
  end,
})
