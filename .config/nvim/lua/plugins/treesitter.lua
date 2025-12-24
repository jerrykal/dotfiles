return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    version = false,
    lazy = false,
    build = ":TSUpdate",
    opts_extend = { "ensure_installed" },
    opts = {
      ensure_installed = {
        "bash",
        "c",
        "cpp",
        "diff",
        "html",
        "javascript",
        "jsdoc",
        "json",
        "jsonc",
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
        callback = function(event)
          local ts = vim.treesitter
          local ft = event.match
          local lang = ts.language.get_lang(ft)

          -- Abort if the parser for the given filtetype is not available
          if lang == nil or not ts.language.add(lang) then
            return
          end

          -- Highlight
          if not vim.g.vscode and ts.query.get(lang, "highlights") ~= nil then
            ts.start(event.buf, lang)
          end

          -- Folds
          if ts.query.get(lang, "folds") ~= nil then
            vim.opt_local.foldmethod = "expr"
            vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
          end

          -- Indent
          if ts.query.get(lang, "indents") ~= nil then
            vim.opt_local.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },

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

  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "LazyFile",
    opts = {
      multiwindow = true,
      mode = "cursor",
      max_lines = 3,
    },
  },
}
