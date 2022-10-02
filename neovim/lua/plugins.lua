return require('packer').startup(function(use)
  -- Let packer manage itself
  use {'wbthomason/packer.nvim', module = 'packer'}

  -- Improve startup time
  use 'lewis6991/impatient.nvim'
  use 'nathom/filetype.nvim'

  use {'kyazdani42/nvim-web-devicons', module = 'nvim-web-devicons'}
  use {'nvim-lua/plenary.nvim', module = 'plenary'}

  use {
    'tpope/vim-surround',
    keys = {
      {'n', 'cs'}, {'n', 'ds'}, {'n', 'ys'}, {'v', 'S'}
    }
  }
  use {'tpope/vim-repeat', after = 'vim-surround'}

  use {
    'numToStr/Comment.nvim',
    keys = {'gc', 'gb'},
    config = function()
      require('Comment').setup()
    end
  }

  use {
    'luukvbaal/stabilize.nvim',
    event = 'BufRead',
    config = function()
      require('stabilize').setup()
    end
  }

  use {
    'akinsho/toggleterm.nvim',
    keys = [[<C-\>]],
    config = function()
      require('toggleterm').setup {
        open_mapping = [[<C-\>]],
        size = 15,
        persist_size = true,
        shade_terminals = false
      }
    end
  }

  use {
    'mbbill/undotree',
    cmd = 'UndotreeToggle',
    setup = function()
      require('mappings').undotree()
    end,
    config = function()
      vim.g.undotree_SetFocusWhenToggle = 1
      vim.g.undotree_SplitWidth = 40
      vim.g.undotree_WindowLayout = 3
    end
  }

  use {
    'rmagatti/auto-session',
    event = 'VimEnter',
    config = function()
      require('auto-session').setup {
        log_level = 'error'
      }
    end
  }

  use {
    'moll/vim-bbye',
    cmd = {'Bdelete', 'Bwipeout'},
    setup = function()
      require('mappings').bbye()
    end
  }

  use {
    'lukas-reineke/indent-blankline.nvim',
    event = 'BufRead',
    config = function()
      require('indent_blankline').setup {
        char = '▏',
        context_char = '▏',
        show_current_context = true,
        buftype_exclude = {'terminal'};
      }
    end
  }

  -- Color Scheme
  use {
    'Mofiqul/vscode.nvim',
    event = 'VimEnter',
    config = [[require('config.colorscheme')]]
  }

  -- Statusline
  use {
    'nvim-lualine/lualine.nvim',
    after = 'vscode.nvim',
    config = [[require('config.lualine')]]
  }

  -- Bufferline
  use {
    'akinsho/bufferline.nvim',
    after = 'vscode.nvim',
    setup = function()
      require('mappings').bufferline()
    end,
    config = [[require('config.bufferline')]]
  }

  -- LSP
  use {
    'neovim/nvim-lspconfig',
    event = 'BufRead',
    requires = {
      'williamboman/nvim-lsp-installer',
      {'hrsh7th/cmp-nvim-lsp', after = 'nvim-lspconfig'}
    },
    config = [[require('config.lsp')]]
  }

  -- Completion
  use {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    requires = {
      {'L3MON4D3/LuaSnip', event = 'InsertEnter'},
      {
        'windwp/nvim-autopairs',
        event = 'InsertEnter',
        config = function() require('nvim-autopairs').setup() end
      }
    },
    config = [[require('config.cmp')]]
  }

  -- Telescope
  use {
    {
      'nvim-telescope/telescope.nvim',
      cmd = 'Telescope',
      setup = function()
        require('mappings').telescope()
      end,
      config = function()
        require('telescope').setup {
          defaults = {
            layout_strategy = 'flex'
          }
        }
      end
    },
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      run = 'make',
      after = 'telescope.nvim',
      config = function()
        require('telescope').load_extension('fzf')
      end
    }
  }

  -- Treesitter
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate',
    event = 'BufRead',
    config = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = 'all',
        highlight = {enable = true}
      }
    end
  }

  -- Git
  use {
    'lewis6991/gitsigns.nvim',
    event = 'BufRead',
    config = function()
      require('gitsigns').setup()
    end
  }

  -- File Explorer
  use {
    'kyazdani42/nvim-tree.lua',
    cmd = 'NvimTreeToggle',
    setup = function()
      require('mappings').nvimtree()
    end,
    config = function()
      require'nvim-tree'.setup()
    end
  }
end)
