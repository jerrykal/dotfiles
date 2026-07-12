return {
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    event = "VeryLazy",
    opts = {
      auto_start = true,
      log_level = "info",
      track_selection = false,
      terminal = {
        provider = "none",
      },
    },
    keys = {
      { "<M-a>", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
      {
        "<M-a>",
        "<cmd>ClaudeCodeTreeAdd<cr>",
        desc = "Add file",
        ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw", "snacks_picker_list" },
      },
      {
        "<M-a>",
        function()
          local s, e = vim.fn.line("v"), vim.fn.line(".")
          if s > e then
            s, e = e, s
          end
          vim.cmd(("ClaudeCodeAdd %% %d %d"):format(s, e))
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
        end,
        mode = "v",
        desc = "Send selection to Claude",
      },
    },
  },
}
