return {
  -- Debug Adapter Protocol client for debugging code in Neovim
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
      { "<c-.>", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
      { "<s-c-.>", function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = "Breakpoint Condition" },
      { "<leader>dl", function() require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: ")) end, desc = "Set Log Point" },
      { "<leader>dc", function() require("dap").continue() end, desc = "Run/Continue" },
      { "<leader>dC", function() require("dap").run_to_cursor() end, desc = "Run to Cursor" },
      { "<leader>dg", function() require("dap").goto_() end, desc = "Go to Line (No Execute)" },
      { "<leader>di", function() require("dap").step_into() end, desc = "Step Into" },
      { "<leader>dj", function() require("dap").down() end, desc = "Down" },
      { "<leader>dk", function() require("dap").up() end, desc = "Up" },
      { "<leader>dL", function() require("dap").run_last() end, desc = "Run Last" },
      { "<leader>do", function() require("dap").step_out() end, desc = "Step Out" },
      { "<leader>dO", function() require("dap").step_over() end, desc = "Step Over" },
      { "<leader>dp", function() require("dap").pause() end, desc = "Pause" },
      { "<leader>ds", function() require("dap").session() end, desc = "Session" },
      { "<leader>dt", function() require("dap").terminate() end, desc = "Terminate" },
      { "<leader>df", function() require("dap").focus_frame() end, desc = "Jump to Current Frame" },
      { "<leader>dh", function() require("dap.ui.widgets").hover() end, desc = "DAP Hover", mode = { "n", "v" } },
      { "<down>", function() require("dap").step_over() end, desc = "Step Over" },
      { "<right>", function() require("dap").step_into() end, desc = "Step Into" },
      { "<left>", function() require("dap").step_out() end, desc = "Step Out" },
      { "<up>", function() require("dap").restart_frame() end, desc = "Step Into" },
    },
  },

  -- Minimal UI for nvim-dap
  {
    "igorlfs/nvim-dap-view",
    opts = {
      winbar = {
        sections = { "watches", "scopes", "exceptions", "breakpoints", "threads", "repl", "console" },
        show_keymap_hints = false,
      },
      windows = {
        size = function(pos)
          return pos == "right" and 0.35 or 0.25
        end,
        terminal = {
          position = "right",
        },
      },
      icons = {
        collapsed = " ",
        expanded = " ",
      },
    },
    -- stylua: ignore
    keys = {
      { "<leader>du", "<cmd>DapViewToggle!<cr>", desc = "Toggle Dap View" },
      { "<leader>dw", "<cmd>DapViewWatch<cr>", desc = "Add to Watch", mode = { "n", "x" } },
      {
        "<leader>dv",
        function()
          local windows = require("dap-view.setup").config.windows
          windows.position = windows.position == "below" and "right" or "below"
          if require("dap-view.util").is_win_valid(require("dap-view.state").winnr) then
            require("dap-view").open(true)
          end
        end,
        desc = "Toggle Dap View Position (Bottom/Right)",
      },
    },
  },

  -- Bridge between mason.nvim and nvim-dap for automatic debugger setup
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

  -- Syntax highlighting in the DAP REPL using treesitter
  -- Must be set up before treesitter installs parsers, so dap_repl is registered
  {
    "nvim-treesitter",
    dependencies = { { "LiadOz/nvim-dap-repl-highlights", opts = {} } },
    opts = { ensure_installed = { "dap_repl" } },
  },

  -- Autocompletion source for DAP REPL using blink.cmp
  {
    "mayromr/blink-cmp-dap",
    ft = { "dap-repl" },
  },
  {
    "blink.cmp",
    opts = {
      sources = {
        per_filetype = {
          ["dap-repl"] = { "dap" },
        },
        providers = {
          dap = {
            name = "dap",
            module = "blink-cmp-dap",
          },
        },
      },
    },
  },
}
