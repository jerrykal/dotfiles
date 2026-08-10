return {
  -- Live markdown rendering with proper formatting in the editor
  {
    "OXY2DEV/markview.nvim",
    lazy = false, -- markview.nvim lazy loads itself
    opts = {},
    config = function(_, opts)
      require("markview").setup(opts)

      -- Disable markview rendering inside codediff views; restore on close.
      -- codediff swaps the real file buffer into the diff window asynchronously
      -- (after the git content fetch), long after CodeDiffOpen/CodeDiffFileSelect
      -- fire, so sweeping the tab on those events alone finds only the empty
      -- placeholder buffers. Track which tabs are diff views instead and disable
      -- each markdown buffer as it lands in one.
      local codediff_tabs = {}
      local codediff_disabled = {}

      local function disable_buf(buf)
        if not vim.api.nvim_buf_is_valid(buf) or vim.bo[buf].filetype ~= "markdown" then
          return
        end
        require("markview.commands").disable(buf)
        codediff_disabled[buf] = true
      end

      local function disable_in_tab(tabpage)
        if not vim.api.nvim_tabpage_is_valid(tabpage) then
          return
        end
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tabpage)) do
          disable_buf(vim.api.nvim_win_get_buf(win))
        end
      end

      vim.api.nvim_create_autocmd("User", {
        pattern = { "CodeDiffOpen", "CodeDiffFileSelect" },
        callback = function(ev)
          local tabpage = (ev.data or {}).tabpage or vim.api.nvim_get_current_tabpage()
          codediff_tabs[tabpage] = true
          vim.schedule(function()
            disable_in_tab(tabpage)
          end)
        end,
      })

      -- Catches buffers displayed after the User events above have fired
      vim.api.nvim_create_autocmd("BufWinEnter", {
        callback = function(ev)
          for _, win in ipairs(vim.fn.win_findbuf(ev.buf)) do
            if codediff_tabs[vim.api.nvim_win_get_tabpage(win)] then
              disable_buf(ev.buf)
              return
            end
          end
        end,
      })

      vim.api.nvim_create_autocmd("User", {
        pattern = "CodeDiffClose",
        callback = function(ev)
          codediff_tabs[(ev.data or {}).tabpage or vim.api.nvim_get_current_tabpage()] = nil
          for tabpage in pairs(codediff_tabs) do
            if not vim.api.nvim_tabpage_is_valid(tabpage) then
              codediff_tabs[tabpage] = nil
            end
          end
          if next(codediff_tabs) then
            return
          end

          local commands = require("markview.commands")
          for buf in pairs(codediff_disabled) do
            if vim.api.nvim_buf_is_valid(buf) then
              commands.enable(buf)
            end
          end
          codediff_disabled = {}
        end,
      })
    end,
  },

  {
    "dkarter/bullets.vim",
    ft = "markdown",
  },
}
