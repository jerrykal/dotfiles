return {
  -- Auto-completion
  {
    "saghen/blink.cmp",
    dependencies = { "rafamadriz/friendly-snippets" },
    version = "1.*",
    event = { "InsertEnter", "CmdlineEnter" },
    opts = {
      keymap = {
        preset = "super-tab",
        ["<C-p>"] = false,
        ["<C-n>"] = false,
        ["<C-j>"] = { "select_next", "fallback_to_mappings" },
        ["<C-k>"] = { "select_prev", "hide_signature", "fallback_to_mappings" },
        ["<C-u>"] = { "scroll_documentation_up", "scroll_signature_up", "fallback" },
        ["<C-d>"] = { "scroll_documentation_down", "scroll_signature_down", "fallback" },
      },
      completion = {
        list = {
          selection = {
            preselect = true,
            auto_insert = true,
          },
        },
      },
      cmdline = {
        keymap = {
          preset = "inherit",
        },
        completion = {
          menu = {
            auto_show = true,
          },
        },
      },
      signature = {
        enabled = true,
        window = {
          show_documentation = true,
        },
      },
      appearance = {
        kind_icons = {
          Array = "",
          Boolean = "",
          Class = "",
          Color = "",
          Constant = "",
          Constructor = "",
          Enum = "",
          EnumMember = "",
          Event = "",
          Field = "",
          File = "",
          Folder = "",
          Function = "",
          Interface = "",
          Keyword = "",
          Method = "",
          Module = "",
          Namespace = "",
          Null = "",
          Object = "",
          Operator = "",
          Package = "",
          Property = "",
          Reference = "",
          Snippet = "",
          Struct = "",
          Text = "",
          TypeParameter = "",
          Unit = "󰪚",
          Value = "",
          Variable = "",
        },
      },
    },
  },

  -- Better yank/paste
  {
    "gbprod/yanky.nvim",
    dependencies = {
      "folke/snacks.nvim",
    },
    event = "LazyFile",
    opts = {
      ring = {
        update_register_on_cycle = true,
      },
      highlight = {
        timer = 150,
      },
    },
    keys = {
      {
        "<leader>p",
        function()
          if not vim.g.vscode then
            Snacks.picker.yanky()
          else
            vim.cmd([[YankyRingHistory]])
          end
        end,
        mode = { "n", "x" },
        desc = "Open yank history",
      },
      -- stylua: ignore
      { "y", "<plug>(YankyYank)", mode = { "n", "x" }, desc = "Yank text" },
      { "p", "<plug>(YankyPutAfter)", mode = { "n", "x" }, desc = "Put yanked text after cursor" },
      { "P", "<plug>(YankyPutBefore)", mode = { "n", "x" }, desc = "Put yanked text before cursor" },
      { "gp", "<plug>(YankyGPutAfter)", mode = { "n", "x" }, desc = "Put yanked text after selection" },
      { "gP", "<plug>(YankyGPutBefore)", mode = { "n", "x" }, desc = "Put yanked text before selection" },
      { "[y", "<plug>(YankyPreviousEntry)", desc = "Select previous entry through yank history" },
      { "]y", "<plug>(YankyNextEntry)", desc = "Select next entry through yank history" },
      { "]p", "<plug>(YankyPutIndentAfterLinewise)", desc = "Put indented after cursor (linewise)" },
      { "[p", "<plug>(YankyPutIndentBeforeLinewise)", desc = "Put indented before cursor (linewise)" },
      { "]P", "<plug>(YankyPutIndentAfterLinewise)", desc = "Put indented after cursor (linewise)" },
      { "[P", "<plug>(YankyPutIndentBeforeLinewise)", desc = "Put indented before cursor (linewise)" },
      { ">p", "<plug>(YankyPutIndentAfterShiftRight)", desc = "Put and indent right" },
      { "<p", "<plug>(YankyPutIndentAfterShiftLeft)", desc = "Put and indent left" },
      { ">P", "<plug>(YankyPutIndentBeforeShiftRight)", desc = "Put before and indent right" },
      { "<P", "<plug>(YankyPutIndentBeforeShiftLeft)", desc = "Put before and indent left" },
      { "=p", "<plug>(YankyPutAfterFilter)", desc = "Put after applying a filter" },
      { "=P", "<plug>(YankyPutBeforeFilter)", desc = "Put before applying a filter" },
    },
  },

  {
    "nvim-mini/mini.surround",
    opts = {
      mappings = {
        add = "gsa", -- Add surrounding in Normal and Visual modes
        delete = "gsd", -- Delete surrounding
        find = "gsf", -- Find surrounding (to the right)
        find_left = "gsF", -- Find surrounding (to the left)
        highlight = "gsh", -- Highlight surrounding
        replace = "gsr", -- Replace surrounding
        update_n_lines = "gsn", -- Update `n_lines`
      },
    },
    keys = {
      { "gs", mode = { "n", "x" } },
    },
  },

  {
    "nvim-mini/mini.ai",
    event = "LazyFile",
    opts = function()
      local ai = require("mini.ai")
      return {
        n_lines = 500,
        custom_textobjects = {
          o = ai.gen_spec.treesitter({ -- code block
            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          }),
          f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }), -- function
          c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }), -- class
          t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" }, -- tags
          d = { "%f[%d]%d+" }, -- digits
          S = { -- subwords
            { "%u[%l%d]+%f[^%l%d]", "%f[%S][%l%d]+%f[^%l%d]", "%f[%P][%l%d]+%f[^%l%d]", "^[%l%d]+%f[^%l%d]" },
            "^().*()$",
          },
          g = function() -- suffer
            local from = { line = 1, col = 1 }
            local to = {
              line = vim.fn.line("$"),
              col = math.max(vim.fn.getline("$"):len(), 1),
            }
            return { from = from, to = to }
          end,
          u = ai.gen_spec.function_call(),
          U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }),
        },
      }
    end,
  },
  {
    "windwp/nvim-autopairs",
    event = { "InsertEnter" },
    opts = {},
  },

  {
    "folke/ts-comments.nvim",
    event = "LazyFile",
    opts = {},
  },

  {
    "Wansmer/treesj",
    keys = {
      { "<leader>j", "<cmd>TSJToggle<cr>", desc = "Join Toggle" },
    },
    opts = { use_default_keymaps = false },
  },

  -- Neovim lua_ls setup
  {
    "folke/lazydev.nvim",
    ft = "lua",
    cmd = "LazyDev",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        { path = "snacks.nvim", words = { "Snacks" } },
        { path = "lazy.nvim", words = { "LazyVim" } },
      },
    },
  },
  {
    "blink.cmp",
    opts = {
      sources = {
        per_filetype = {
          lua = { inherit_defaults = true, "lazydev" },
        },
        providers = {
          lazydev = {
            name = "LazyDev",
            module = "lazydev.integrations.blink",
            score_offset = 100,
          },
        },
      },
    },
  },
}
