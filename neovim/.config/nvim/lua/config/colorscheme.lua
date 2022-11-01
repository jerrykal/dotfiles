vim.o.background = "dark"

local c = require("vscode.colors")
require("vscode").setup({
  -- Tweak some colors
  color_overrides = {
    vscSearch = "#613214",
  },
  group_overrides = {
    ["@string.escape"] = { fg = c.vscYellowOrange, bold = true },
    CursorLine = { bg = c.vscBack },
    NvimTreeCursorLine = { bg = c.vscLeftDark },
  },
})
