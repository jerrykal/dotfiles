return {
  -- LSP
  {
    "neovim/nvim-lspconfig",
    event = "BufReadPre",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "j-hui/fidget.nvim",
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    opts = {
      servers = {
        clangd = {},
        pyright = {
          settings = {
            python = {
              analysis = {
                diagnosticMode = "workspace",
                typeCheckingMode = "off",
              },
            },
          },
        },
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = { globals = { "vim" } },
            },
            format = {
              enable = false,
            },
          },
        },
      },
    },
    config = function(_, opts)
      require("mason-lspconfig").setup({
        automatic_installation = true,
      })

      -- Setup lsp servers
      local on_attach = function(client, buffer)
        require("plugins.lsp.keymaps").setup(client, buffer)
      end
      local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())

      for server, server_opts in pairs(opts.servers) do
        server_opts.on_attach = on_attach
        server_opts.capabilities = capabilities
        require("lspconfig")[server].setup(server_opts)
      end

      -- Setup fidget.nvim
      require("fidget").setup()

      -- Setup diagnostics
      vim.diagnostic.config({
        virtual_text = { prefix = "● " },
        serverity_sort = true,
      })
      vim.fn.sign_define("DiagnosticSignError", { text = "", numhl = "DiagnosticError" })
      vim.fn.sign_define("DiagnosticSignWarn", { text = "", numhl = "DiagnosticWarn" })
      vim.fn.sign_define("DiagnosticSignInfo", { text = "", numhl = "DiagnosticInfo" })
      vim.fn.sign_define("DiagnosticSignHint", { text = "", numhl = "DiagnosticHint" })
    end,
  },

  -- Formatters
  {
    "jose-elias-alvarez/null-ls.nvim",
    event = "BufReadPre",
    dependencies = "mason.nvim",
    opts = function()
      local nls = require("null-ls")
      return {
        sources = {
          nls.builtins.formatting.black,
          nls.builtins.formatting.isort,
          nls.builtins.formatting.stylua,
        },
      }
    end,
  },

  -- LSP server and Cmdline tools manager
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    opts = {
      ensure_installed = {
        "black",
        "isort",
        "stylua",
      },
    },
    config = function(_, opts)
      require("mason").setup()
      for _, tool in ipairs(opts.ensure_installed) do
        local package = require("mason-registry").get_package(tool)
        if not package:is_installed() then
          package:install()
        end
      end
    end,
  },

  -- Previewing native LSP's goto definition, type definition, implementation, and references calls in floating windows
  {
    "rmagatti/goto-preview",
    opts = {
      post_open_hook = function(_, win)
        vim.api.nvim_win_set_option(win, "winhighlight", "Normal:")
      end,
    },
  },
}
