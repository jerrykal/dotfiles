return require("packer").startup(function(use)
  -- Let packer manage itself
  use({ "wbthomason/packer.nvim", module = "packer" })

  -- Improve startup time
  use("lewis6991/impatient.nvim")
  use("nathom/filetype.nvim")

  use({ "kyazdani42/nvim-web-devicons", module = "nvim-web-devicons" })
  use({ "nvim-lua/plenary.nvim", module = "plenary" })
  use({ "MunifTanjim/nui.nvim", module = "nui" })

  use({
    "tpope/vim-surround",
    keys = {
      { "n", "cs" },
      { "n", "ds" },
      { "n", "ys" },
      { "v", "S" },
    },
  })

  use({
    "Vimjas/vim-python-pep8-indent",
    ft = { "python" },
  })

  use({
    "tpope/vim-repeat",
    keys = {
      { "n", "." },
    },
  })

  use({
    "ggandor/leap.nvim",
    config = function()
      require("leap").add_default_mappings()
    end,
  })

  use({
    "numToStr/Comment.nvim",
    keys = { "gc", "gb" },
    config = function()
      require("Comment").setup()
    end,
  })

  use({
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup()
    end,
  })

  use({
    "RRethy/vim-illuminate",
    event = "BufReadPre",
    config = function()
      require("illuminate").configure({
        filetypes_denylist = { "neo-tree" },
      })
    end,
  })

  use({
    "luukvbaal/stabilize.nvim",
    config = function()
      require("stabilize").setup()
    end,
  })

  use({
    "akinsho/toggleterm.nvim",
    keys = [[<C-\>]],
    config = function()
      require("toggleterm").setup({
        open_mapping = [[<C-\>]],
        size = 15,
        persist_size = true,
        shade_terminals = false,
      })
    end,
  })

  use({
    "rmagatti/auto-session",
    config = function()
      require("auto-session").setup({
        log_level = "error",
      })
    end,
  })

  use({
    "moll/vim-bbye",
    cmd = { "Bdelete", "Bwipeout" },
  })

  use({
    "lukas-reineke/indent-blankline.nvim",
    config = function()
      require("indent_blankline").setup({
        char = "▏",
        context_char = "▏",
        show_current_context = true,
        filetype_exclude = { "neo-tree", "Trouble" },
        buftype_exclude = { "terminal", "help", "prompt" },
      })
    end,
  })

  use({
    "folke/trouble.nvim",
    cmd = "TroubleToggle",
    config = function()
      require("trouble").setup()
    end,
  })

  -- Color Scheme
  use({
    "rebelot/kanagawa.nvim",
    config = function()
      require("config.colorscheme")
    end,
  })

  -- Bufferline
  use({
    "akinsho/bufferline.nvim",
    after = "kanagawa.nvim",
    config = function()
      require("config.bufferline")
    end,
  })

  -- LSP
  use({
    "neovim/nvim-lspconfig",
    event = "BufReadPre",
    requires = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
      "jose-elias-alvarez/null-ls.nvim",
      "SmiteshP/nvim-navic",
      "j-hui/fidget.nvim",
    },
    config = function()
      require("config.lsp")
    end,
  })
  use({
    "rmagatti/goto-preview",
    config = function()
      require("goto-preview").setup({})
    end,
  })

  -- Autocompletion
  use({
    "hrsh7th/nvim-cmp",
    module = "cmp",
    requires = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-nvim-lua",
      "hrsh7th/cmp-path",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      require("config.cmp")
    end,
  })

  -- Snippets
  use({
    "L3MON4D3/LuaSnip",
    module = "luasnip",
    requires = {
      "rafamadriz/friendly-snippets",
    },
  })

  -- Telescope
  use({
    {
      "nvim-telescope/telescope.nvim",
      cmd = "Telescope",
      config = function()
        require("config.telescope")
      end,
    },
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      run = "make",
      after = "telescope.nvim",
      config = function()
        require("telescope").load_extension("fzf")
      end,
    },
    use({
      "prochri/telescope-all-recent.nvim",
      requires = { "kkharji/sqlite.lua" },
      after = "telescope.nvim",
      config = function()
        require("telescope-all-recent").setup({})
      end,
    }),
  })

  -- Treesitter
  use({
    "nvim-treesitter/nvim-treesitter",
    requires = {
      "nvim-treesitter/nvim-treesitter-context",
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    run = ":TSUpdate",
    config = function()
      require("config.treesitter")
    end,
  })

  -- Git
  use({
    "lewis6991/gitsigns.nvim",
    config = function()
      require("config.gitsigns")
    end,
  })
  use({
    "TimUntersberger/neogit",
    config = function()
      require("neogit").setup()
    end,
  })

  -- File Explorer
  use({
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v2.x",
    cmd = "Neotree",
    config = function()
      require("config.neo-tree")
    end,
  })
end)
