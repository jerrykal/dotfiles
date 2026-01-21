return {
  {
    "nvim-lspconfig",
    opts = {
      servers = {
        basedpyright = {
          settings = {
            basedpyright = {
              analysis = {
                typeCheckingMode = "basic",
              },
            },
          },
        },
        ruff = {},
      },
    },
  },

  {
    "conform.nvim",
    opts = {
      formatters_by_ft = {
        python = { "ruff_fix", "ruff_organize_imports", "ruff_format" },
      },
    },
  },

  {
    "mfussenegger/nvim-dap-python",
    dependencies = { "mason-nvim-dap.nvim" },
    -- stylua: ignore
    keys = {
      { "<leader>dPt", function() require('dap-python').test_method() end, desc = "Debug Method", ft = "python" },
      { "<leader>dPc", function() require('dap-python').test_class() end, desc = "Debug Class", ft = "python" },
    },
    config = function()
      require("dap-python").setup("debugpy-adapter")
    end,
  },

  {
    "mason-nvim-dap.nvim",
    opts = {
      ensure_installed = {
        "python",
      },
    },
  },

  {
    "linux-cultist/venv-selector.nvim",
    cmd = "VenvSelect",
    ft = "python",
    opts = {
      options = {
        notify_user_on_venv_activation = true,
      },
    },
    keys = { { "<leader>cv", "<cmd>:VenvSelect<cr>", desc = "Select VirtualEnv", ft = "python" } },
  },
}
