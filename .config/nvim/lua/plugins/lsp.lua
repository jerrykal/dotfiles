return {
  {
    "neovim/nvim-lspconfig",
    event = "LazyFile",
    dependencies = {
      "mason.nvim",
      { "mason-org/mason-lspconfig.nvim", config = function() end },
      "snacks.nvim",
      "nvim-navic",
      "fidget.nvim",
    },
    opts = {
      -- LSP Server configs
      servers = {
        -- Global configs applied to all servers
        ["*"] = {
          workspace = {
            fileOperations = {
              didRename = true,
              willRename = true,
            },
          },
        },
      },
      diagnostics = {
        underline = true,
        update_in_insert = false,
        virtual_text = false, -- use tiny-inline-diagnostic instead
        severity_sort = true,
        signs = false,
      },
      inlay_hints = {
        enabled = true,
        exclude = {}, -- filetypes for which you don't want to enable inlay hints
      },
    },
    config = vim.schedule_wrap(function(_, opts)
      -- Diagnostics
      vim.diagnostic.config(opts.diagnostics)

      -- Inlay hints
      if opts.inlay_hints.enabled then
        Snacks.util.lsp.on({ method = "textDocument/inlayHint" }, function(bufnr)
          if
            vim.api.nvim_buf_is_valid(bufnr)
            and vim.bo[bufnr].buftype == ""
            and not vim.tbl_contains(opts.inlay_hints.exclude, vim.bo[bufnr].filetype)
          then
            vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
          end
        end)
      end

      -- Configure LSP servers
      if opts.servers["*"] then
        -- Setup global configuration first
        vim.lsp.config("*", opts.servers["*"])
      end
      local function configure(server)
        if server == "*" then
          return false
        end

        -- Configure lsp servers
        local server_opts = opts.servers[server]
        if type(server_opts) == "function" then
          server_opts = server_opts()
        end
        vim.lsp.config(server, server_opts)
        return true
      end

      local installed_servers = vim.tbl_filter(configure, vim.tbl_keys(opts.servers))
      require("mason-lspconfig").setup({
        ensure_installed = installed_servers,
      })
    end),
    -- stylua: ignore
    keys = {
      { "gd", function() Snacks.picker.lsp_definitions() end, desc = "Goto Definition" },
      { "grr", function() Snacks.picker.lsp_references() end, desc = "Goto References" },
      { "gri", function() Snacks.picker.lsp_implementations() end, desc = "Goto Implementation" },
      { "grt", function() Snacks.picker.lsp_type_definitions() end, desc = "Goto Type Definition" },
      { "grd", function() Snacks.picker.lsp_declarations() end, desc = "Goto Declaration" },
      { "gai", function() Snacks.picker.lsp_incoming_calls() end, desc = "C[a]lls Incoming" },
      { "gao", function() Snacks.picker.lsp_outgoing_calls() end, desc = "C[a]lls Outgoing" },
      { "<leader>ss", function () Snacks.picker.lsp_symbols() end, desc = "Document Symbols"},
      { "<leader>sS", function () Snacks.picker.lsp_symbols() end, desc = "Workspace Symbols"},

      { "K", vim.lsp.buf.hover, desc = "Hover"},
      { "gk", vim.lsp.buf.signature_help, desc = "Signature Help"},
      { "<c-k>", mode = { "i" }, vim.lsp.buf.signature_help, desc = "Signature Help" },
      { "<leader>ca", mode = { "n", "x" }, vim.lsp.buf.code_action, desc = "Code Action" },
      { "<leader>cr", mode = { "n", "x" }, vim.lsp.codelens.run , desc = "Run Codelens"},
      { "<leader>cR", mode = { "n", "x" }, vim.lsp.codelens.refresh , desc = "Refresh & Display Codelens"},
      { "<leader>rn", vim.lsp.buf.rename , desc = "Rename"},
    },
  },

  {
    "mason-org/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
    opts_extend = { "ensure_installed" },
    opts = {
      ensure_installed = {},
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
