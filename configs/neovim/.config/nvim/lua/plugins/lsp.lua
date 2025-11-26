return {
  {
    "neovim/nvim-lspconfig",
    event = "LazyFile",
    dependencies = {
      "mason-org/mason.nvim",
      { "mason-org/mason-lspconfig.nvim", config = function() end },
      { "j-hui/fidget.nvim", opts = {} },
      "folke/snacks.nvim",
    },
    opts = {
      diagnostics = {
        underline = true,
        update_in_insert = false,
        virtual_text = false, -- use tiny-inline-diagnostic instead
        severity_sort = true,
        signs = false,
      },

      -- LSP servers listed here will be automatically installed
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

        -- Shell script
        bashls = {},

        -- Fish script
        fish_lsp = {},
      },
    },
    config = vim.schedule_wrap(function(_, opts)
      -- Keymaps
      local map = Snacks.keymap.set

      -- stylua: ignore start
      map("n", "gd", Snacks.picker.lsp_definitions, { lsp = { method = "textDocument/defnition" }, desc = "Goto Definition" })
      map("n", "gr", Snacks.picker.lsp_references, { lsp = { method = "textDocument/references" }, no_wait = true , desc = "References" })
      map("n", "gI", Snacks.picker.lsp_implementations, { lsp = { method = "textDocument/implementation" },  desc = "Goto Implementation" })
      map("n", "gy", Snacks.picker.lsp_type_definitions, { lsp = { method = "textDocument/typeDefinition" },  desc = "Goto T[y]pe Definition" })
      map("n", "gD", Snacks.picker.lsp_declarations, { lsp = { method = "textDocument/declaration" }, desc = "Goto Declaration" })
      map("n", "gai", Snacks.picker.lsp_incoming_calls, { lsp = { method = "callHierarchy/incomingCalls" }, desc = "C[a]lls Incoming" })
      map("n", "gao", Snacks.picker.lsp_outgoing_calls, { lsp = { method = "callHierarchy/outgoingCalls" }, desc = "C[a]lls Outgoing" })
      map("n", "<leader>ss", Snacks.picker.lsp_symbols, { lsp = { method = "textDocument/documentSymbol" }, desc = "LSP Symbols" })
      map("n", "<leader>sS", Snacks.picker.lsp_workspace_symbols, { lsp = { method = "workspace/symbol" }, desc = "LSP Workspace Symbols" })

      map("n", "K", vim.lsp.buf.hover, { lsp = { method = "textDocument/hover" }, desc = "Hover" })
      map("n", "gk", vim.lsp.buf.hover, { lsp = { method = "textDocument/signatureHelp" }, desc = "Signature Help" })
      map("i", "<c-k>", vim.lsp.buf.signature_help, { lsp = { method = "textDocument/signatureHelp" }, desc = "Signature Help" })
      map({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, { lsp = { method = "textDocument/codeAction" }, desc = "Code Action" })
      map({ "n", "x" }, "<leader>cc", vim.lsp.codelens.run, { lsp = { method = "textDocument/codeLens" }, desc = "Run Codelens" })
      map("n", "<leader>cC", vim.lsp.codelens.refresh, { lsp = { method = "textDocument/codeLens" }, desc = "Refresh & Display Codelens" })
      map("n", "<leader>rf", Snacks.rename.rename_file, { lsp = { method = "workspace/didRenameFiles" }, desc = "Rename File" })
      map("n", "<leader>rf", Snacks.rename.rename_file, { lsp = { method = "workspace/willRenameFiles" }, desc = "Rename File" })
      map("n", "<leader>rn", vim.lsp.buf.rename, { lsp = { method = "textDocument/rename" }, desc = "Rename" })
      map("n", "]]", function()
        Snacks.words.jump(vim.v.count1, true)
      end, { lsp = { method = "textDocument/documentHighlight" }, desc = "Next Reference", enabled = Snacks.words.is_enabled})
      map("n", "[[", function()
        Snacks.words.jump(-vim.v.count1, true)
      end, { lsp = { method = "textDocument/documentHighlight" }, desc = "Prev Reference", enabled = Snacks.words.is_enabled})
      map("n", "<a-n>", function()
        Snacks.words.jump(vim.v.count1, true)
      end, { lsp = { method = "textDocument/documentHighlight" }, desc = "Next Reference", enabled = Snacks.words.is_enabled})
      map("n", "<a-p>", function()
        Snacks.words.jump(-vim.v.count1, true)
      end, { lsp = { method = "textDocument/documentHighlight" }, desc = "Prev Reference", enabled = Snacks.words.is_enabled})
      -- stylua: ignore end

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

  {
    "mason-org/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
    opts = {
      ensure_installed = {
        "shfmt",
      },
    },
    config = function(_, opts)
      require("mason").setup(opts)

      local mr = require("mason-registry")
      mr.refresh(function()
        for _, pkg_name in ipairs(opts.ensure_installed) do
          local p = mr.get_package(pkg_name)
          if not p:is_installed() then
            p:install()
          end
        end
      end)
    end,
  },
}
