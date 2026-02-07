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

  -- Lightweight session management
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {},
    config = function(_, opts)
      require("persistence").setup(opts)

      local function save_breakpoints()
        local ok, breakpoints = pcall(require, "dap.breakpoints")
        if not ok or not breakpoints then
          return
        end

        local bps = {}
        for bufnr, buf_bps in pairs(breakpoints.get()) do
          local fname = vim.api.nvim_buf_get_name(bufnr)
          bps[fname] = buf_bps
        end
        vim.g.BREAKPOINTS = bps
      end

      local function load_breakpoints()
        local ok, breakpoints = pcall(require, "dap.breakpoints")
        if not ok or not breakpoints or not vim.g.BREAKPOINTS then
          return
        end

        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          local fname = vim.api.nvim_buf_get_name(buf)
          local buf_bps = vim.g.BREAKPOINTS[fname]
          if buf_bps ~= nil then
            for _, bp in pairs(buf_bps) do
              local line = bp.line
              local bp_opts = {
                condition = bp.condition,
                log_message = bp.logMessage,
                hit_condition = bp.hitCondition,
              }
              breakpoints.set(bp_opts, vim.fn.bufnr(buf), line)
            end
          end
        end
      end

      local augroup = vim.api.nvim_create_augroup("persist-breakpoints", { clear = true })
      vim.api.nvim_create_autocmd("User", {
        group = augroup,
        pattern = "PersistenceSavePre",
        callback = save_breakpoints,
      })
      vim.api.nvim_create_autocmd("User", {
        group = augroup,
        pattern = "PersistenceLoadPost",
        callback = load_breakpoints,
      })
    end,
    -- stylua: ignore
    keys = {
      { "<leader>qs", function() require("persistence").load() end, desc = "Restore Session" },
      { "<leader>qS", function() require("persistence").select() end,desc = "Select Session" },
      { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore Last Session" },
      { "<leader>qd", function() require("persistence").stop() end, desc = "Don't Save Current Session" },
    },
  },
}
