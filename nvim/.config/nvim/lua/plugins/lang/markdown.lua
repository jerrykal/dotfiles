return {
  -- Live markdown rendering with proper formatting in the editor
  {
    "OXY2DEV/markview.nvim",
    lazy = false, -- markview.nvim lazy loads itself
    opts = {},
    config = function(_, opts)
      require("markview").setup(opts)

      -- Disable markview rendering inside codediff views; restore on close
      local codediff_disabled = {}

      local function disable_in_tab()
        local commands = require("markview.commands")
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
          local buf = vim.api.nvim_win_get_buf(win)
          if vim.bo[buf].filetype == "markdown" and not codediff_disabled[buf] then
            commands.disable(buf)
            codediff_disabled[buf] = true
          end
        end
      end

      vim.api.nvim_create_autocmd("User", {
        pattern = { "CodeDiffOpen", "CodeDiffFileSelect" },
        callback = vim.schedule_wrap(disable_in_tab),
      })

      vim.api.nvim_create_autocmd("User", {
        pattern = "CodeDiffClose",
        callback = function()
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
