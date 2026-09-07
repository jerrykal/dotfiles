local M = {}

-- fzf-style CTRL-T: open a file picker seeded with the path-like text
-- before the cursor; confirming replaces that text with the picked path
-- and resumes insert mode after it. Multi-selected paths are joined with
-- a prompted delimiter, in selection order.
function M.pick()
  -- close any open completion menu, or it sticks over the picker
  local ok, cmp = pcall(require, "blink.cmp")
  if ok then
    cmp.cancel()
  end
  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_get_current_buf()
  local from_insert = vim.api.nvim_get_mode().mode:find("i") ~= nil
  local row, col = unpack(vim.api.nvim_win_get_cursor(win))
  local before = vim.api.nvim_get_current_line():sub(1, col)
  local prefix = before:match("[%w%._%-~/%$@%+]+$") or ""

  local function insert_text(text)
    if not (vim.api.nvim_win_is_valid(win) and vim.api.nvim_buf_is_valid(buf)) then
      return
    end
    if row > vim.api.nvim_buf_line_count(buf) then
      return
    end
    -- the line may have changed since pick() (e.g. InsertLeave strips
    -- autoindent), so re-anchor on the typed prefix instead of trusting
    -- the saved columns
    local line = vim.api.nvim_buf_get_lines(buf, row - 1, row, true)[1]
    local e = math.min(col, #line)
    local s = e
    if prefix ~= "" and line:sub(e - #prefix + 1, e) == prefix then
      s = e - #prefix
    end
    local rep = vim.split(text, "\n", { plain = true })
    vim.api.nvim_set_current_win(win)
    vim.api.nvim_buf_set_text(buf, row - 1, s, row - 1, e, rep)
    local end_row = row + #rep - 1
    local end_col = #rep == 1 and s + #rep[1] or #rep[#rep]
    if not from_insert then
      -- invoked from normal mode: stay in normal mode on the last inserted byte
      vim.api.nvim_win_set_cursor(win, { end_row, math.max(end_col - 1, 0) })
    elseif vim.api.nvim_get_mode().mode:find("i") then
      vim.api.nvim_win_set_cursor(win, { end_row, end_col })
    else
      -- land on the last inserted byte, then `a` to continue typing after it
      vim.api.nvim_win_set_cursor(win, { end_row, math.max(end_col - 1, 0) })
      vim.api.nvim_feedkeys("a", "n", false)
    end
  end

  Snacks.picker.files({
    title = "Insert File Path",
    pattern = prefix,
    confirm = function(picker)
      local items = picker:selected({ fallback = true })
      picker:close()
      if #items == 0 then
        return
      end
      local paths = vim.tbl_map(function(it)
        return it.file
      end, items)
      vim.schedule(function()
        if #paths == 1 then
          insert_text(paths[1])
          return
        end
        vim.ui.input({ prompt = "Delimiter: ", default = ", " }, function(delim)
          if not delim then
            return
          end
          delim = delim:gsub("\\n", "\n"):gsub("\\t", "\t")
          insert_text(table.concat(paths, delim))
        end)
      end)
    end,
  })
end

return M
