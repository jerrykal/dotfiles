return {
  -- Fast icon provider for files, filetypes and other UI elements
  {
    "nvim-mini/mini.icons",
    lazy = true,
    opts = {},
    config = function(_, opts)
      require("mini.icons").setup(opts)
      MiniIcons.mock_nvim_web_devicons()
    end,
  },

  -- Display LSP diagnostics inline at end of line instead of virtual text
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "LazyFile",
    opts = {
      preset = "powerline",
      options = {
        severity = {
          vim.diagnostic.severity.ERROR,
          vim.diagnostic.severity.WARN,
          vim.diagnostic.severity.INFO,
        },
        multilines = {
          enabled = true,
          severity = {
            vim.diagnostic.severity.ERROR,
            vim.diagnostic.severity.WARN,
            vim.diagnostic.severity.INFO,
          },
        },
      },
    },
  },

  -- LSP progress notifications in the corner of the editor
  {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    opts = {},
  },

  -- Winbar breadcrumbs showing path and code context, with clickable menus
  {
    "Bekaboo/dropbar.nvim",
    lazy = false, -- handles its own lazy-loading via plugin/dropbar.lua
    dependencies = {
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    opts = {
      bar = {
        -- default sources minus path: symbols only
        sources = function(buf, _)
          local sources = require("dropbar.sources")
          local utils = require("dropbar.utils")
          if vim.bo[buf].ft == "markdown" then
            return { sources.markdown }
          end
          if vim.bo[buf].buftype == "terminal" then
            return { sources.terminal }
          end
          return { sources.lsp }
        end,
      },
      icons = {
        kinds = {
          symbols = require("util.kind_icons").get(true),
        },
        ui = {
          bar = {
            separator = " ",
          },
          menu = {
            indicator = "",
          },
        },
      },
    },
    -- stylua: ignore
    keys = {
      { "<leader>;", function() require("dropbar.api").pick() end, desc = "Pick symbols in winbar", },
      { "[;", function() require("dropbar.api").goto_context_start() end, desc = "Go to start of current context", },
      { "];", function() require("dropbar.api").select_next_context() end, desc = "Select next context", },
    },
  },
}
