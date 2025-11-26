return {
  {
    "neovim/nvim-lspconfig",
    event = "LazyFile",
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
      { "mason-org/mason-lspconfig.nvim", config = function() end },
    },
    opts = {
      diagnostics = {
        underline = true,
        update_in_insert = false,
        virtual_text = false, -- use tiny-inline-diagnostic instead
        severity_sort = true,
        signs = false,
      },
      servers = {
        ["*"] = {
          capabilities = {
            workspace = {
              fileOperations = {
                didRename = true,
                willRename = true,
              },
            },
          },
        },

        -- Python
        basedpyright = {},
        ruff = {},

        -- Lua
        lua_ls = {
          settings = {
            Lua = {
              --- Disable lua_ls formatter, use stylua instead
              format = {
                enable = false,
              },
              workspace = {
                checkThirdParty = false,
              },
              codeLens = {
                enable = true,
              },
              completion = {
                callSnippet = "Replace",
              },
              doc = {
                privateName = { "^_" },
              },
              hint = {
                enable = true,
                setType = false,
                paramType = true,
                paramName = "Disable",
                semicolon = "Disable",
                arrayIndex = "Disable",
              },
            },
          },
        },
        stylua = {},
      },
    },
    config = vim.schedule_wrap(function(_, opts)
      -- Diagnostics
      vim.diagnostic.config(opts.diagnostics)

      if opts.servers["*"] then
        vim.lsp.config("*", opts.servers["*"])
      end

      local function configure(server)
        -- Global configurations for all servers
        if server == "*" then
          return false
        end

        -- Configure lsp servers
        local server_opts = opts.servers[server]
        vim.lsp.config(server, server_opts)
        return true
      end

      local installed_servers = vim.tbl_filter(configure, vim.tbl_keys(opts.servers))
      require("mason-lspconfig").setup({
        ensure_installed = installed_servers,
      })
    end),
  },
}
