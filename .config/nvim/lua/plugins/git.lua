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
        map("n", "ghs", gitsigns.stage_hunk, "Stage Hunk")
        map("n", "ghr", gitsigns.reset_hunk, "Reset Hunk")
        map("v", "ghs", function() gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Stage Hunk")
        map("v", "ghr", function() gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Reset Hunk")
        map("n", "ghS", gitsigns.stage_buffer, "Stage Buffer")
        map("n", "ghR", gitsigns.reset_buffer, "Reset buffer")
        map("n", "ghp", gitsigns.preview_hunk, "Preview Hunk")
        map("n", "ghi", gitsigns.preview_hunk_inline, "Preview Hunk Inline")

        map("n", "ghb", function() gitsigns.blame_line({ full = true }) end, "Blame Line")
        map("n", "ghB", function() gitsigns.blame() end, "Blame Buffer")

        map("n", "ghd", gitsigns.diffthis, "Diff This")
        map("n", "ghD", function() gitsigns.diffthis("~") end, "Diff This ~")

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
      { "<leader>gv", "<cmd>DiffviewOpen<cr>", desc = "Open Diffview" },
      { "<leader>ghb", "<cmd>DiffviewFileHistory<cr>", desc = "Open File History Diffview(Branch)" },
      { "<leader>ghf", "<cmd>DiffviewFileHistory %<cr>", desc = "Open File History Diffview(Current File)" },
    },
  },
}
