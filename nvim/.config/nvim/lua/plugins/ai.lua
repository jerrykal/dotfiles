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
        -- Inside tmux, reuse the prefix-. claude pane (env-forwarded so claude
        -- auto-connects to this nvim); elsewhere no managed terminal.
        provider = vim.env.TMUX and "external" or "none",
        provider_opts = {
          external_terminal_cmd = function(_, env)
            local argv = { vim.fn.expand("~/.tmux/scripts/claude-pane.sh"), vim.fn.getcwd() }
            for k, v in pairs(env) do
              table.insert(argv, ("%s=%s"):format(k, v))
            end
            return argv
          end,
        },
      },
    },
    keys = {
      { "<M-c>", "<cmd>ClaudeCodeFocus<cr>", mode = { "n", "v" }, desc = "Focus/open Claude pane" },
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
