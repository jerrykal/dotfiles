return {
  -- LSP
  {
    "neovim/nvim-lspconfig",
    event = "BufReadPre",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      { "j-hui/fidget.nvim", tag = "legacy" },
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      {

        "SmiteshP/nvim-navbuddy",
        dependencies = {
          "SmiteshP/nvim-navic",
        },
      },
      { "folke/neoconf.nvim", cmd = "Neoconf", config = false, dependencies = { "nvim-lspconfig" } },
    },
    opts = {
      servers = {
        clangd = {
          cmd = {
            "clangd",
          },
          filetypes = { "c", "cpp", "objc", "objcpp" },
        },
        pyright = {
          settings = {
            python = {
              analysis = {
                diagnosticMode = "openFilesOnly",
              },
            },
          },
        },
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = { globals = { "vim" } },
            },
          },
        },
        bashls = {},
      },
      format = {
        formatting_options = nil,
        timeout_ms = nil,
      }
    },
    config = function(_, opts)
      require("mason-lspconfig").setup({
        automatic_installation = true,
      })

      -- Setup lsp servers
      local on_attach = function(client, buffer)
        require("nvim-navbuddy").attach(client, buffer)
        require("plugins.lsp.keymaps").setup(client, buffer)
      end
      local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())

      for server, server_opts in pairs(opts.servers) do
        server_opts.on_attach = on_attach

        if server == "clangd" then
          capabilities.offsetEncoding = { "utf-16" }
        end
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
    "nvimtools/none-ls.nvim",
    event = "BufReadPre",
    dependencies = "mason.nvim",
    opts = function()
      local nls = require("null-ls")
      return {
        sources = {
          nls.builtins.formatting.black,
          nls.builtins.formatting.isort,
          nls.builtins.formatting.stylua,
          nls.builtins.formatting.shfmt.with({ extra_args = { "-i", "2" } }),
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
        "shfmt",
        "shellcheck",
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
    -- stylua: ignore
    keys = {
      { "n", "gpd", "<cmd>lua require('goto-preview').goto_preview_definition()<cr>", desc = "Preview Definition" },
      { "n", "gpt", "<cmd>lua require('goto-preview').goto_preview_type_definition()<cr>", desc = "Preview Type Definition" },
      { "n", "gpi", "<cmd>lua require('goto-preview').goto_preview_implementation()<cr>", desc = "Preview Implementation" },
      { "n", "gpr", "<cmd>lua require('goto-preview').goto_preview_references()<cr>", desc = "Preview References" },
      { "n", "gP", "<cmd>lua require('goto-preview').close_all_win()<cr>", desc = "Close All Preview Windows" },
    },
    opts = {
      post_open_hook = function(_, win)
        vim.api.nvim_win_set_option(win, "winhighlight", "Normal:")
      end,
    },
  },

  -- Symbol outlines
  {
    "stevearc/aerial.nvim",
    cmd = "AerialToggle",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    keys = {
      { "n", "<leader>a", "<cmd>AerialToggle<cr>", desc = "Toggle Aerial" },
    },
    opts = {
      backends = { "lsp", "treesitter", "markdown", "man" },
      layout = {
        min_width = 28,
        default_direction = "right",
        placement = "edge",
      },
      attach_mode = "global",
      filter_kind = false,
      icons = {
        Class = " ",
        Constant = " ",
        Constructor = " ",
        Enum = " ",
        EnumMember = " ",
        Event = " ",
        Field = " ",
        File = " ",
        Function = " ",
        Interface = " ",
        Key = " ",
        Method = " ",
        Module = " ",
        Operator = " ",
        Property = " ",
        String = " ",
        Struct = " ",
        TypeParameter = " ",
        Variable = " ",
      },
    },
  },
}
