return {
  -- Syntax highlighting and code understanding using tree-sitter parsers
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    version = false,
    lazy = false,
    build = ":TSUpdate",
    opts_extend = {
      "indent",
      "highlight.disable",
      "folds.disable",
      "ensure_installed.disable",
    },
    opts = {
      indent = {
        enable = true,
        disable = {},
      },
      highlight = {
        enable = true,
        disable = {},
      },
      folds = {
        enable = true,
        disable = {},
      },
      ensure_installed = {
        "bash",
        "c",
        "cpp",
        "diff",
        "html",
        "javascript",
        "jsdoc",
        "json",
        "lua",
        "luadoc",
        "luap",
        "markdown",
        "markdown_inline",
        "printf",
        "python",
        "query",
        "regex",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "xml",
        "yaml",
      },
    },
    config = function(_, opts)
      local TS = require("nvim-treesitter")
      TS.setup()

      -- Install parsers
      TS.install(opts.ensure_installed)

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("treesitter", { clear = true }),
        callback = function(ev)
          local ts = vim.treesitter
          local ft = ev.match
          local lang = ts.language.get_lang(ft)

          -- Abort if the parser for the given filtetype is not available
          if lang == nil or not ts.language.add(lang) then
            return
          end

          ---@param feat string
          ---@param query string
          local function enabled(feat, query)
            local f = opts[feat] or {}
            return f.enable ~= false
              and not (type(f.disable) == "table" and vim.tbl_contains(f.disable, lang))
              and ts.query.get(lang, query) ~= nil
          end

          -- Highlight
          if not vim.g.vscode and enabled("highlight", "highlights") then
            pcall(vim.treesitter.start, ev.buf)
          end

          -- Folds
          if enabled("folds", "folds") then
            vim.opt_local.foldmethod = "expr"
            vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
          end

          -- Indent
          if enabled("indent", "indents") then
            vim.opt_local.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },

  -- Advanced text objects for functions, classes, parameters using treesitter
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    event = "VeryLazy",
    opts = {
      select = { lookahead = true },
    },
    config = function(_, opts)
      require("nvim-treesitter-textobjects").setup(opts)

      local map = vim.keymap.set

      -- stylua: ignore start
      -- Swap
      map("n", "<leader>>", function() require("nvim-treesitter-textobjects.swap").swap_next("@parameter.inner") end)
      map("n", "<leader><", function() require("nvim-treesitter-textobjects.swap").swap_previous("@parameter.outer") end)

      -- Move
      map({ "n", "x", "o" }, "]f", function() require("nvim-treesitter-textobjects.move").goto_next_start("@function.outer", "textobjects") end)
      map({ "n", "x", "o" }, "]c", function() require("nvim-treesitter-textobjects.move").goto_next_start("@class.outer", "textobjects") end)
      map({ "n", "x", "o" }, "]a", function() require("nvim-treesitter-textobjects.move").goto_next_start("@parameter.outer", "textobjects") end)
      map({ "n", "x", "o" }, "]F", function() require("nvim-treesitter-textobjects.move").goto_next_end("@function.outer", "textobjects") end)
      map({ "n", "x", "o" }, "]C", function() require("nvim-treesitter-textobjects.move").goto_next_end("@class.outer", "textobjects") end)
      map({ "n", "x", "o" }, "]A", function() require("nvim-treesitter-textobjects.move").goto_next_end("@parameter.outer", "textobjects") end)
      map({ "n", "x", "o" }, "[f", function() require("nvim-treesitter-textobjects.move").goto_previous_start("@function.outer", "textobjects") end)
      map({ "n", "x", "o" }, "[c", function() require("nvim-treesitter-textobjects.move").goto_previous_start("@class.outer", "textobjects") end)
      map({ "n", "x", "o" }, "[a", function() require("nvim-treesitter-textobjects.move").goto_previous_start("@parameter.outer", "textobjects") end)
      map({ "n", "x", "o" }, "[F", function() require("nvim-treesitter-textobjects.move").goto_previous_end("@function.outer", "textobjects") end)
      map({ "n", "x", "o" }, "[C", function() require("nvim-treesitter-textobjects.move").goto_previous_end("@class.outer", "textobjects") end)
      map({ "n", "x", "o" }, "[A", function() require("nvim-treesitter-textobjects.move").goto_previous_end("@parameter.outer", "textobjects") end)
      -- stylua: ignore end
    end,
  },

  -- Show current function/class context at the top of the window
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "LazyFile",
    opts = {
      multiwindow = true,
      max_lines = 5,
    },
  },
}
