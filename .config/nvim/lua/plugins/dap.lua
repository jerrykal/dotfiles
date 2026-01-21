return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "mason-nvim-dap.nvim",
      "nvim-dap-view",
      "plenary.nvim",
    },
    config = function()
      vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "DiagnosticError" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "", texthl = "DiagnosticError" })
      vim.fn.sign_define("DapBreakpointRejected", { text = "", texthl = "DiagnosticError" })
      vim.fn.sign_define("DapLogPoint", { text = "", texthl = "DiagnosticError" })
      vim.fn.sign_define(
        "DapStopped",
        { text = ">", texthl = "DiagnosticWarn", linehl = "DapStoppedLine", numhl = "DapStoppedLine" }
      )

      -- Setup dap config by VsCode launch.json file
      local json = require("plenary.json")
      require("dap.ext.vscode").json_decode = function(str)
        return vim.json.decode(json.json_strip_comments(str))
      end
    end,
    -- stylua: ignore
    keys = {
      { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = "Breakpoint Condition" },
      { "<leader>dl", function() require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: ")) end, desc = "Set Log Point" },
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
      { "<leader>dc", function() require("dap").continue() end, desc = "Run/Continue" },
      { "<leader>dC", function() require("dap").run_to_cursor() end, desc = "Run to Cursor" },
      { "<leader>dg", function() require("dap").goto_() end, desc = "Go to Line (No Execute)" },
      { "<leader>di", function() require("dap").step_into() end, desc = "Step Into" },
      { "<leader>dj", function() require("dap").down() end, desc = "Down" },
      { "<leader>dk", function() require("dap").up() end, desc = "Up" },
      { "<leader>dL", function() require("dap").run_last() end, desc = "Run Last" },
      { "<leader>do", function() require("dap").step_out() end, desc = "Step Out" },
      { "<leader>dO", function() require("dap").step_over() end, desc = "Step Over" },
      { "<leader>dP", function() require("dap").pause() end, desc = "Pause" },
      { "<leader>ds", function() require("dap").session() end, desc = "Session" },
      { "<leader>dt", function() require("dap").terminate() end, desc = "Terminate" },
    },
  },

  -- Dap UI
  {
    "igorlfs/nvim-dap-view",
    -- Let the plugin lazy load itself
    lazy = false,
    opts = {
      windows = {
        size = 0.4,
        position = "right",
        terminal = {
          position = "below",
        },
      },
    },
    -- stylua: ignore
    keys = {
      { "<leader>du", "<cmd>DapViewToggle!<cr>", desc = "Toggle Dap View" },
      { "<leader>dw", "<cmd>DapViewWatch<cr>", desc = "Add to Watch", mode = { "n", "x" } },
    },
  },

  -- mason.nvim integration
  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = "mason.nvim",
    cmd = { "DapInstall", "DapUninstall" },
    opts = {
      automatic_installation = true,
      handlers = {},
      ensure_installed = {},
    },
  },
}
