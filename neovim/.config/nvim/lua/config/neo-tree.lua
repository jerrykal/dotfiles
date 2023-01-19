require("neo-tree").setup({
  enable_modified_markers = false,
  use_popups_for_input = false,
  source_selector = {
    winbar = true,
    tab_labels = {
      filesystem = "  Files ",
      buffers = "  Buffers ",
      git_status = "  Git ",
      diagnostics = " 裂Diagnostics ",
    },
    content_layout = "center",
  },
  filesystem = {
    follow_current_file = true,
    filtered_items = {
      visible = true,
      hide_dotfiles = false,
      hide_gitignored = true,
    },
  },
  default_component_configs = {
    indent = {
      with_expanders = true,
      expander_collapsed = "",
      expander_expanded = ""
    },
    icon = {
      folder_closed = "",
      folder_open = "",
      folder_empty = "",
      folder_empty_open = "",
      default = "",
    },
    git_status = {
      symbols = {
        added = "A",
        deleted = "D",
        modified = "M",
        renamed = "R",
        untracked = "U",
        ignored = "",
        unstaged = "",
        staged = "",
      },
    },
    diagnostics = {
      symbols = {
        hint = "  ",
        info = "  ",
        warn = "  ",
        error = "  ",
      },
      highlights = {
        hint = "DiagnosticSignHint",
        info = "DiagnosticSignInfo",
        warn = "DiagnosticSignWarn",
        error = "DiagnosticSignError",
      },
    },
  },
})
