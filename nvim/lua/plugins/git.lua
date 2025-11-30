return {
  -- Lazygit integration
  {
    "snacks.nvim",
    -- stylua: ignore
    keys = {
      { "<leader>gg", function() Snacks.lazygit() end, desc = "Lazygit", },
      { "<leader>gB", function() Snacks.gitbrowse() end, desc = "Git Browse", mode = { "n", "v" } },
    },
  },

  -- Git integration for buffers
  {
    "lewis6991/gitsigns.nvim",
    event = "LazyFile",
    opts = {
      signs = {
        add = { text = "▏" },
        change = { text = "▏" },
        delete = { text = "-" },
        topdelete = { text = "-" },
        changedelete = { text = "▏" },
        untracked = { text = "▏" },
      },
      signs_staged = {
        add = { text = "▏" },
        change = { text = "▏" },
        delete = { text = "-" },
        topdelete = { text = "-" },
        changedelete = { text = "▏" },
      },
      current_line_blame = true,
      on_attach = function(bufnr)
        local gitsigns = require("gitsigns")

        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc, silent = true })
        end

        -- stylua: ignore start
        -- Actions
        map("n", "]h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "]h", bang = true })
          else
            gitsigns.nav_hunk("next")
            gitsigns.preview_hunk_inline()
          end
        end, "Next Hunk")
        map("n", "[h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "[h", bang = true })
          else
            gitsigns.nav_hunk("prev")
            gitsigns.preview_hunk_inline()
          end
        end, "Prev Hunk")
        map("n", "<leader>ghs", gitsigns.stage_hunk, "Stage Hunk")
        map("n", "<leader>ghr", gitsigns.reset_hunk, "Reset Hunk")
        map("v", "<leader>ghs", function() gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Stage Hunk")
        map("v", "<leader>ghr", function() gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Reset Hunk")
        map("n", "<leader>ghS", gitsigns.stage_buffer, "Stage Buffer")
        map("n", "<leader>ghR", gitsigns.reset_buffer, "Reset buffer")
        map("n", "<leader>ghp", gitsigns.preview_hunk_inline, "Preview Hunk Inline")

        map("n", "<leader>ghb", function() gitsigns.blame_line({ full = true }) end, "Blame Line")
        map("n", "<leader>ghB", function() gitsigns.blame() end, "Blame Buffer")

        map("n", "<leader>ghd", gitsigns.diffthis, "Diff This")
        map("n", "<leader>ghD", function() gitsigns.diffthis("~") end, "Diff This ~")

        -- Toggle
        map("n", "<leader>gtb", gitsigns.toggle_current_line_blame, "Toggle Current Line Blame")

        -- Text object
        map({ "o", "x" }, "ih", gitsigns.select_hunk, "GitSigns Select Hunk")
        -- stylua: ignore end
      end,
    },
  },

  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },
    opts = {
      file_panel = {
        win_config = { position = "right" },
      },
    },
    keys = {
      { "<leader>gD", "<cmd>DiffviewOpen<cr>", desc = "Open Diffview" },
      { "<leader>gHb", "<cmd>DiffviewFileHistory<cr>", desc = "Open File History Diffview(Branch)" },
      { "<leader>gHf", "<cmd>DiffviewFileHistory %<cr>", desc = "Open File History Diffview(Current File)" },
    },
  },
}
