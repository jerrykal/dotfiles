return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    version = false,
    build = ":TSUpdate",
    event = { "VeryLazy" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    lazy = vim.fn.argc(-1) == 0, -- load treesitter early when opening a file from the cmdline
    init = function(plugin)
      require("lazy.core.loader").add_to_rtp(plugin)
      require("nvim-treesitter.query_predicates")
    end,
    cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
    opts = {
      ensure_installed = {
        "bash",
        "c",
        "cpp",
        "fish",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "query",
        "vim",
        "vimdoc",
        "yaml",
      },
      highlight = { enable = true },
      indent = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "+",
          node_incremental = "+",
          node_decremental = "-",
        },
      },
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ["if"] = "@function.inner",
            ["af"] = "@function.outer",
            ["ic"] = "@class.inner",
            ["ac"] = "@class.outer",
            ["i,"] = "@parameter.inner",
            ["a,"] = "@parameter.outer",
          },
          include_surrounding_whitespace = false,
        },
        swap = {
          enable = true,
          swap_next = {
            ["<leader>>"] = "@parameter.inner",
          },
          swap_previous = {
            ["<leader><"] = "@parameter.inner",
          },
        },
        move = {
          enable = true,
          goto_next_start = {
            ["]f"] = "@function.outer",
            ["]c"] = "@class.outer",
            ["]a"] = "@parameter.inner",
          },
          goto_next_end = {
            ["]F"] = "@function.outer",
            ["]C"] = "@class.outer",
            ["]A"] = "@parameter.inner",
          },
          goto_previous_start = {
            ["[f"] = "@function.outer",
            ["[c"] = "@class.outer",
            ["[a"] = "@parameter.inner",
          },
          goto_previous_end = {
            ["[F"] = "@function.outer",
            ["[C"] = "@class.outer",
            ["[A"] = "@parameter.inner",
          },
        },
      },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-context",
    branch = "master",
    event = "LazyFile",
    opts = {
      multiwindow = true,
    },
  },

  -- {
  --   "nvim-treesitter/nvim-treesitter",
  --   branch = "main",
  --   event = "VeryLazy",
  --   build = ":TSUpdate",
  --   opts = {
  --     ensure_installed = {
  --       "bash",
  --       "c",
  --       "cpp",
  --       "fish",
  --       "lua",
  --       "markdown",
  --       "markdown_inline",
  --       "python",
  --       "query",
  --       "vim",
  --       "vimdoc",
  --       "yaml",
  --     },
  --   },
  --   config = function(_, opts)
  --     local TS = require("nvim-treesitter")
  --     TS.setup(opts)
  --
  --     -- Install parsers
  --     TS.install(opts.ensure_installed)
  --
  --     vim.api.nvim_create_autocmd("FileType", {
  --       group = vim.api.nvim_create_augroup("treesitter", { clear = true }),
  --       callback = function(event)
  --         local ft = event.match
  --         local lang = vim.treesitter.language.get_lang(ft)
  --
  --         -- Abort if the parser for the given filtetype is not available
  --         if not vim.treesitter.language.add(lang) then
  --           return
  --         end
  --
  --         -- Highlight
  --         vim.treesitter.start(event.buf, lang)
  --
  --         -- Folds
  --         vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
  --
  --         -- Indent
  --         vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  --       end,
  --     })
  --   end,
  -- },
  --
  -- {
  --   "nvim-treesitter/nvim-treesitter-textobjects",
  --   branch = "main",
  --   event = "VeryLazy",
  --   opts = {
  --     select = { lookahead = true },
  --   },
  --   config = function(_, opts)
  --     require("nvim-treesitter-textobjects").setup(opts)
  --
  --     local map = vim.keymap.set
  --
  --     -- Select
  --     -- stylua: ignore start
  --     map({ "x", "o" }, "af", function() require("nvim-treesitter-textobjects.select").select_textobject("@function.outer", "textobjects") end)
  --     map({ "x", "o" }, "if", function() require("nvim-treesitter-textobjects.select").select_textobject("@function.inner", "textobjects") end)
  --     map({ "x", "o" }, "ac", function() require("nvim-treesitter-textobjects.select").select_textobject("@class.outer", "textobjects") end)
  --     map({ "x", "o" }, "ic", function() require("nvim-treesitter-textobjects.select").select_textobject("@class.inner", "textobjects") end)
  --     map({ "x", "o" }, "a,", function() require("nvim-treesitter-textobjects.select").select_textobject("@parameter.outer", "textobjects") end)
  --     map({ "x", "o" }, "i,", function() require("nvim-treesitter-textobjects.select").select_textobject("@parameter.inner", "textobjects") end)
  --
  --     -- Swap
  --     map("n", "<leader>>", function() require("nvim-treesitter-textobjects.swap").swap_next("@parameter.inner") end)
  --     map("n", "<leader><", function() require("nvim-treesitter-textobjects.swap").swap_previous("@parameter.outer") end)
  --
  --     -- Move
  --     map({ "n", "x", "o" }, "]f", function() require("nvim-treesitter-textobjects.move").goto_next_start("@function.outer", "textobjects") end)
  --     map({ "n", "x", "o" }, "]c", function() require("nvim-treesitter-textobjects.move").goto_next_start("@class.outer", "textobjects") end)
  --     map({ "n", "x", "o" }, "]a", function() require("nvim-treesitter-textobjects.move").goto_next_start("@parameter.outer", "textobjects") end)
  --     map({ "n", "x", "o" }, "]F", function() require("nvim-treesitter-textobjects.move").goto_next_end("@function.outer", "textobjects") end)
  --     map({ "n", "x", "o" }, "]C", function() require("nvim-treesitter-textobjects.move").goto_next_end("@class.outer", "textobjects") end)
  --     map({ "n", "x", "o" }, "]A", function() require("nvim-treesitter-textobjects.move").goto_next_end("@parameter.outer", "textobjects") end)
  --     map({ "n", "x", "o" }, "[f", function() require("nvim-treesitter-textobjects.move").goto_previous_start("@function.outer", "textobjects") end)
  --     map({ "n", "x", "o" }, "[c", function() require("nvim-treesitter-textobjects.move").goto_previous_start("@class.outer", "textobjects") end)
  --     map({ "n", "x", "o" }, "[a", function() require("nvim-treesitter-textobjects.move").goto_previous_start("@parameter.outer", "textobjects") end)
  --     map({ "n", "x", "o" }, "[F", function() require("nvim-treesitter-textobjects.move").goto_previous_end("@function.outer", "textobjects") end)
  --     map({ "n", "x", "o" }, "[C", function() require("nvim-treesitter-textobjects.move").goto_previous_end("@class.outer", "textobjects") end)
  --     map({ "n", "x", "o" }, "[A", function() require("nvim-treesitter-textobjects.move").goto_previous_end("@parameter.outer", "textobjects") end)
  --     -- stylua: ignore end
  --   end,
  -- },
}
