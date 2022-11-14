require("telescope").setup({
  defaults = {
    cycle_layout_list = { "horizontal", "vertical" },
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
      ".git",
      "node_modules",
    },
  },
})
