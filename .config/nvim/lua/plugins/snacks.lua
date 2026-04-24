return {
  {
    "folke/snacks.nvim",
    lazy = false,
    priority = 1000,
    dependencies = { "mini.icons" },
    opts = {
      -- Pickers
      explorer = {
        replace_netrw = false,
      },
      picker = {
        prompt = " ",
        sources = {
          directories = {
            title = "Directories",
            hidden = true,
            ignored = false,
            finder = function(opts, ctx)
              local args = { "--type", "d", "--color", "never", "-E", ".git" }

              if opts.hidden then
                table.insert(args, "--hidden")
              end
              if opts.ignored then
                table.insert(args, "--no-ignore")
              end

              return require("snacks.picker.source.proc").proc(
                ctx:opts({
                  cmd = "fd",
                  args = args,
                  cwd = ctx:cwd(),
                  transform = function(item)
                    item.cwd = ctx:cwd()
                    item.file = item.text
                    item.dir = true
                  end,
                }),
                ctx
              )
            end,
            format = "file",
            preview = "file",
            show_empty = true,
            supports_live = true,
            confirm = function(picker, item)
              picker:close()
              if item then
                vim.schedule(function()
                  require("oil").open(require("snacks.picker.util").path(item))
                end)
              end
            end,
          },
          files = { hidden = true },
          grep = { hidden = true },
          explorer = {
            hidden = true,
            ignored = true,
            layout = { preset = "right" },
          },
          lsp_symbols = {
            -- Focus on current symbol on show
            on_show = function(picker)
              local function cursor_in_range(cursor, range)
                local row, col = cursor[1] - 1, cursor[2]
                return (row > range.start.line or (row == range.start.line and col >= range.start.character))
                  and (row < range["end"].line or (row == range["end"].line and col <= range["end"].character))
              end

              local cursor = vim.api.nvim_win_get_cursor(picker.main)
              local symbols = picker:items()
              for i = #symbols, 1, -1 do
                if cursor_in_range(cursor, symbols[i].range) then
                  picker.list.cursor = symbols[i].idx
                  return
                end
              end
            end,
          },
        },
        win = {
          input = {
            keys = {
              ["<C-p>"] = { "history_back", mode = { "i", "n" } },
              ["<C-n>"] = { "history_forward", mode = { "i", "n" } },
              ["<a-s>"] = { "flash", mode = { "n", "i" } },
              ["s"] = { "flash" },
            },
          },
        },
        actions = {
          flash = function(picker)
            require("flash").jump({
              pattern = "^",
              label = { after = { 0, 0 } },
              search = {
                mode = "search",
                exclude = {
                  function(win)
                    return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "snacks_picker_list"
                  end,
                },
              },
              action = function(match)
                local idx = picker.list:row2idx(match.pos[1])
                picker.list:_move(idx, true, true)
              end,
            })
          end,
        },
        icons = {
          ui = {
            selected = "▏",
            unselected = " ",
          },
          kinds = require("util.kind_icons").get(true),
        },
      },

      -- UI
      indent = {
        indent = {
          char = "▏",
        },
        scope = {
          char = "▏",
        },
        animate = {
          enabled = false,
        },
      },
      notifier = {},
      scope = {},
      statuscolumn = {
        left = { "sign", "mark" },
      },
      words = {},
      styles = {
        notification = {
          wo = { wrap = true },
        },
      },

      -- Utilities
      bigfile = {},
      image = {},
      quickfile = {},
      scratch = {
        ft = "markdown",
      },
    },
    -- stylua: ignore
    keys = {
      -- Top Pickers & Explorer
      { "<C-p>", function() Snacks.picker.smart() end, desc = "Smart Find Files" },
      { "<leader>,", function() Snacks.picker.buffers() end, desc = "Buffers" },
      { "<leader>/", function() Snacks.picker.grep() end, desc = "Grep" },
      { "<leader>:", function() Snacks.picker.command_history() end, desc = "Command History" },
      { "<leader>n", function() Snacks.picker.notifications() end, desc = "Notification History" },
      { "<leader>e", function() Snacks.explorer() end, desc = "File Explorer" },

      -- Find
      { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers" },
      { "<leader>fd", function() Snacks.picker.directories() end, desc = "Find Directories" },
      { "<leader>fm", function() Snacks.picker.buffers({ modified = true }) end, desc = "Modified Buffers" },
      { "<leader>fc", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Find Config File" },
      { "<leader>ff", function() Snacks.picker.files() end, desc = "Find Files" },
      { "<leader>fg", function() Snacks.picker.git_files() end, desc = "Find Git Files" },
      { "<leader>fp", function() Snacks.picker.projects() end, desc = "Projects" },
      { "<leader>fr", function() Snacks.picker.recent() end, desc = "Recent" },

      -- Git
      { "<leader>gb", function() Snacks.picker.git_branches() end, desc = "Git Branches" },
      { "<leader>gl", function() Snacks.picker.git_log() end, desc = "Git Log" },
      { "<leader>gL", function() Snacks.picker.git_log_line() end, desc = "Git Log Line" },
      { "<leader>gs", function() Snacks.picker.git_status() end, desc = "Git Status" },
      { "<leader>gS", function() Snacks.picker.git_stash() end, desc = "Git Stash" },
      { "<leader>gd", function() Snacks.picker.git_diff() end, desc = "Git Diff (Hunks)" },
      { "<leader>gf", function() Snacks.picker.git_log_file() end, desc = "Git Log File" },

      -- Github
      { "<leader>gi", function() Snacks.picker.gh_issue() end, desc = "GitHub Issues (open)" },
      { "<leader>gI", function() Snacks.picker.gh_issue({ state = "all" }) end, desc = "GitHub Issues (all)" },
      { "<leader>gp", function() Snacks.picker.gh_pr() end, desc = "GitHub Pull Requests (open)" },
      { "<leader>gP", function() Snacks.picker.gh_pr({ state = "all" }) end, desc = "GitHub Pull Requests (all)" },

      -- Grep
      { "<leader>sb", function() Snacks.picker.lines() end, desc = "Buffer Lines" },
      { "<leader>sB", function() Snacks.picker.grep_buffers() end, desc = "Grep Open Buffers" },
      { "<leader>sw", function() Snacks.picker.grep_word() end, desc = "Visual selection or word", mode = { "n", "x" } },

      -- Search
      { '<leader>s"', function() Snacks.picker.registers() end, desc = "Registers" },
      { '<leader>s/', function() Snacks.picker.search_history() end, desc = "Search History" },
      { "<leader>sa", function() Snacks.picker.autocmds() end, desc = "Autocmds" },
      { "<leader>sc", function() Snacks.picker.command_history() end, desc = "Command History" },
      { "<leader>sC", function() Snacks.picker.commands() end, desc = "Commands" },
      { "<leader>sd", function() Snacks.picker.diagnostics() end, desc = "Diagnostics" },
      { "<leader>sD", function() Snacks.picker.diagnostics_buffer() end, desc = "Buffer Diagnostics" },
      { "<leader>sh", function() Snacks.picker.help() end, desc = "Help Pages" },
      { "<leader>sH", function() Snacks.picker.highlights() end, desc = "Highlights" },
      { "<leader>si", function() Snacks.picker.icons() end, desc = "Icons" },
      { "<leader>sj", function() Snacks.picker.jumps() end, desc = "Jumps" },
      { "<leader>sk", function() Snacks.picker.keymaps() end, desc = "Keymaps" },
      { "<leader>sl", function() Snacks.picker.loclist() end, desc = "Location List" },
      { "<leader>sm", function() Snacks.picker.marks() end, desc = "Marks" },
      { "<leader>sM", function() Snacks.picker.man() end, desc = "Man Pages" },
      { "<leader>sp", function() Snacks.picker.lazy() end, desc = "Search for Plugin Spec" },
      { "<leader>sq", function() Snacks.picker.qflist() end, desc = "Quickfix List" },
      { "<leader>sR", function() Snacks.picker.resume() end, desc = "Resume" },
      { "<leader>su", function() Snacks.picker.undo() end, desc = "Undo History" },

      -- Git
      { "<leader>gg", function() Snacks.lazygit() end, desc = "Lazygit", },
      { "<leader>gB", function() Snacks.gitbrowse() end, desc = "Git Browse", mode = { "n", "v" } },

      -- Others
      { "<leader>bd", function() Snacks.bufdelete() end, desc = "Delete Buffer" },
      { "<leader>rf", function() Snacks.rename.rename_file() end, desc = "Rename File" },
      { "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications" },
      { "]]", function() Snacks.words.jump(vim.v.count1) end, desc = "Next Reference", mode = { "n", "t" } },
      { "[[", function() Snacks.words.jump(-vim.v.count1) end, desc = "Prev Reference", mode = { "n", "t" } },
      { "<a-n>", function() Snacks.words.jump(vim.v.count1) end, desc = "Next Reference", mode = { "n", "t" } },
      { "<a-p>", function() Snacks.words.jump(-vim.v.count1) end, desc = "Prev Reference", mode = { "n", "t" } },
      { "<leader>z",  function() Snacks.zen.zoom() end, desc = "Toggle Zoom" },
      { "<leader>.", function() Snacks.scratch() end, desc = "Toggle Scratch Buffer" },
      { "<leader>S", function() Snacks.scratch.select() end, desc = "Select Scratch Buffer" },
    },
    init = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        callback = function()
          Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
          Snacks.toggle.inlay_hints():map("<leader>uh")
        end,
      })
    end,
  },
}
