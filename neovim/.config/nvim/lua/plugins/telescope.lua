return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = {
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        config = function()
          require("telescope").load_extension("fzf")
        end,
      },
    },
    opts = {
      defaults = {
        winblend = 10,
        borderchars = { " ", " ", " ", " ", " ", " ", " ", " " },
        cycle_layout_list = { "horizontal", "vertical" },
        pickers = {
          live_grep = {
            -- Search hidden files
            additional_args = function(_)
              return { "--hidden" }
            end,
          },
        },
        layout_config = {
          vertical = {
            preview_height = 0.5,
          },
          flex = {
            flip_columns = 160,
          },
          horizontal = {
            preview_width = 0.5,
          },
          height = 0.85,
          width = 0.85,
          preview_cutoff = 0,
        },
        vimgrep_arguments = {
          "rg",
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "--smart-case",
          "--hidden",
        },
        prompt_prefix = "   ",
        selection_caret = "  ",
        entry_prefix = "  ",
        layout_strategy = "flex",
        file_ignore_patterns = {
          ".git/",
          "node_modules/",
          "__pycache__/",
        },
      },
      pickers = {
        find_files = {
          hidden = true,
        },
      },
    },
    keys = {
      { "<c-p>", "<cmd>Telescope find_files<cr>", { desc = "Find Files" } },
      { "<leader>/", "<cmd>Telescope live_grep<cr>", { desc = "Find in Files (Grep)" } },
      { "<leader>:", "<cmd>Telescope command_history<cr>", { desc = "Show Command History" } },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Buffers" } },
      { "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Files" } },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "Help Pages" } },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Old Files" } },
    },
  },
}
