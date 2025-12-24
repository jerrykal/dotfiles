return {
  {
    "snacks.nvim",
    opts = {
      bigfile = {},
      image = {},
      quickfile = {},
      scratch = {
        ft = "markdown",
      },
    },
    -- stylua: ignore
    keys = {
      { "<leader>z",  function() Snacks.zen.zoom() end, desc = "Toggle Zoom" },
      { "<leader>.", function() Snacks.scratch() end, desc = "Toggle Scratch Buffer" },
      { "<leader>S", function() Snacks.scratch.select() end, desc = "Select Scratch Buffer" },
    },
  },

  {
    "rmagatti/auto-session",
    lazy = false,
    opts = {
      session_lens = {
        picker = "snacks",
        mappings = {
          delete_session = { { "i", "n" }, "<C-x>" },
        },
      },
      -- Save & restore DAP breakpoints
      save_extra_data = function(_)
        local dap_plugin = require("lazy.core.config").plugins["nvim-dap"]
        if not dap_plugin or not dap_plugin._.loaded then
          return
        end

        local ok, breakpoints = pcall(require, "dap.breakpoints")
        if not ok or not breakpoints then
          return
        end

        local bps = {}
        local breakpoints_by_buf = breakpoints.get()
        for buf, buf_bps in pairs(breakpoints_by_buf) do
          bps[vim.api.nvim_buf_get_name(buf)] = buf_bps
        end
        if vim.tbl_isempty(bps) then
          return
        end
        local extra_data = {
          breakpoints = bps,
        }
        return vim.fn.json_encode(extra_data)
      end,
      restore_extra_data = function(_, extra_data)
        local json = vim.fn.json_decode(extra_data)

        if json.breakpoints then
          local ok, breakpoints = pcall(require, "dap.breakpoints")

          if not ok or not breakpoints then
            return
          end
          for buf_name, buf_bps in pairs(json.breakpoints) do
            for _, bp in pairs(buf_bps) do
              local line = bp.line
              local opts = {
                condition = bp.condition,
                log_message = bp.logMessage,
                hit_condition = bp.hitCondition,
              }
              breakpoints.set(opts, vim.fn.bufnr(buf_name), line)
            end
          end
        end
      end,
    },
    keys = {
      { "<leader>fs", "<cmd>AutoSession search<cr>", desc = "Sessions" },
    },
  },
}
