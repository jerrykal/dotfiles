return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    event = "VeryLazy",
    build = ":TSUpdate",
    opts = {},
    config = function(_, opts)
      local TS = require("nvim-treesitter")
      TS.setup(opts)

      -- Install parsers
      local ensure_installed = {
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
      }
      TS.install(ensure_installed)

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("treesitter", { clear = true }),
        callback = function(event)
          local ft = event.match
          local lang = vim.treesitter.language.get_lang(ft)

          -- Abort if the parser for the given filtetype is not available
          if not vim.treesitter.language.add(lang) then
            return
          end

          -- Highlight
          vim.treesitter.start(event.buf, lang)

          -- Folds
          vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"

          -- Indent
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    event = "VeryLazy",
    opts = {
      -- TODO: Set this up
    },
  },
  -- {
  --   "nvim-treesitter/nvim-treesitter",
  --   version = false,
  --   build = ":TSUpdate",
  --   event = { "VeryLazy" },
  --   dependencies = {
  --     "nvim-treesitter/nvim-treesitter-textobjects",
  --   },
  --   lazy = vim.fn.argc(-1) == 0, -- load treesitter early when opening a file from the cmdline
  --   init = function(plugin)
  --     require("lazy.core.loader").add_to_rtp(plugin)
  --     require("nvim-treesitter.query_predicates")
  --   end,
  --   cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
  --   opts = {
  --     ensure_installed = {
  --       "c",
  --       "lua",
  --       "markdown",
  --       "markdown_inline",
  --       "python",
  --       "query",
  --       "vim",
  --       "vimdoc",
  --     },
  --     highlight = { enable = true },
  --     indent = { enable = true },
  --     incremental_selection = {
  --       enable = true,
  --       keymaps = {
  --         init_selection = "+",
  --         node_incremental = "+",
  --         node_decremental = "-",
  --       },
  --     },
  --     textobjects = {
  --       select = {
  --         enable = true,
  --         lookahead = true,
  --         keymaps = {
  --           ["af"] = "@function.outer",
  --           ["if"] = "@function.inner",
  --           ["ic"] = "@class.inner",
  --           ["ac"] = "@class.outer",
  --           ["i,"] = "@parameter.inner",
  --           ["a,"] = "@parameter.outer",
  --         },
  --         include_surrounding_whitespace = false,
  --       },
  --       swap = {
  --         enable = true,
  --         swap_next = {
  --           ["<leader>>"] = "@parameter.inner",
  --         },
  --         swap_previous = {
  --           ["<leader><"] = "@parameter.inner",
  --         },
  --       },
  --       move = {
  --         enable = true,
  --         goto_next_start = {
  --           ["]f"] = "@function.outer",
  --           ["]c"] = "@class.outer",
  --           ["]a"] = "@parameter.inner",
  --         },
  --         goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer", ["]A"] = "@parameter.inner" },
  --         goto_previous_start = {
  --           ["[f"] = "@function.outer",
  --           ["[c"] = "@class.outer",
  --           ["[a"] = "@parameter.inner",
  --         },
  --         goto_previous_end = {
  --           ["[F"] = "@function.outer",
  --           ["[C"] = "@class.outer",
  --           ["[A"] = "@parameter.inner",
  --         },
  --       },
  --     },
  --   },
  --   config = function(_, opts)
  --     require("nvim-treesitter.configs").setup(opts)
  --   end,
  -- },
}
