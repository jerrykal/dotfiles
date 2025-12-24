return {
  {
    "neovim/nvim-lspconfig",
    event = "LazyFile",
    dependencies = {
      "mason.nvim",
      { "mason-org/mason-lspconfig.nvim", config = function() end },
      "snacks.nvim",
      "fidget.nvim",
      "nvim-navic",
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
        exclude = {}, -- filetypes for which you don't want to enable inlay hints
      },
    },
    config = vim.schedule_wrap(function(_, opts)
      -- Diagnostics
      vim.diagnostic.config(opts.diagnostics)

      -- Inlay hints
      Snacks.util.lsp.on({ method = "textDocument/inlayHint" }, function(bufnr)
        if
          vim.api.nvim_buf_is_valid(bufnr)
          and vim.bo[bufnr].buftype == ""
          and not vim.tbl_contains(opts.inlay_hints.exclude, vim.bo[bufnr].filetype)
        then
          vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
        end
      end)

      -- Folds
      Snacks.util.lsp.on({ method = "textDocument/foldingRange" }, function()
        vim.opt_local.foldmethod = "expr"
        vim.opt_local.foldexpr = "v:lua.vim.lsp.foldexpr()"
      end)

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

  -- CLI tools and LSP package manager
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

  {
    "SmiteshP/nvim-navic",
    dependencies = { "snacks.nvim" },
    lazy = true,
    opts = {
      lsp = {
        auto_attach = true,
      },
      highlight = true,
      separator = "  ",
      depth_limit_indicator = "…",
      click = true,
      icons = require("util.kind_icons").get(true),
    },
    config = function(_, opts)
      require("nvim-navic").setup(opts)

      vim.api.nvim_create_autocmd({ "TermOpen", "BufEnter", "BufWinEnter", "BufWritePost", "FileType", "LspAttach" }, {
        group = vim.api.nvim_create_augroup("navic_winbar", { clear = true }),
        pattern = "*",
        callback = function(args)
          for _, win in ipairs(vim.fn.win_findbuf(args.buf)) do
            local buf = vim._resolve_bufnr(args.buf)
            local stat = vim.uv.fs_stat(vim.api.nvim_buf_get_name(buf))
            if
              not vim.api.nvim_buf_is_valid(buf)
              or not vim.api.nvim_win_is_valid(win)
              or vim.fn.win_gettype(win) ~= ""
              or vim.wo[win].winbar ~= ""
              or vim.bo[buf].ft == "help"
              or stat and stat.size > 1024 * 1024
              or vim.tbl_isempty(vim.lsp.get_clients({
                bufnr = buf,
                method = "textDocument/documentSymbol",
              }))
            then
              return
            end

            vim.wo[win][0].winbar = "  %{%v:lua.require'nvim-navic'.get_location()%}"
          end
        end,
      })
    end,
  },

  {
    "j-hui/fidget.nvim",
    lazy = true,
    opts = {},
  },
}
