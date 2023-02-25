return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
    },
    config = function()
      vim.fn.sign_define(
        "DapBreakpoint",
        { text = "", texthl = "debugBreakpoint", linehl = "", numhl = "" }
      )
      vim.fn.sign_define(
        "DapBreakpointCondition",
        { text = "", texthl = "debugBreakpoint", linehl = "", numhl = "" }
      )
      vim.fn.sign_define(
        "DapBreakpointRejected",
        { text = "", texthl = "debugBreakpoint", linehl = "", numhl = "" }
      )
      vim.fn.sign_define(
        "DapLogPoint",
        { text = "", texthl = "debugBreakpoint", linehl = "", numhl = "" }
      )
      vim.fn.sign_define(
        "DapStopped",
        { text = "", texthl = "DiagnosticWarn", linehl = "debugPC", numhl = "" }
      )
    end,
  },

  {
    "rcarriga/nvim-dap-ui",
    opts = {},
    config = function(_, opts)
      require("dapui").setup(opts)
    end,
  },

  {
    "mfussenegger/nvim-dap-python",
    config = function(_, _)
      require("dap-python").setup("~/.venv/debugpy/bin/python")
    end,
  },
}
