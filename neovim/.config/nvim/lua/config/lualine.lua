require("lualine").setup({
  sections = {
    lualine_x = { "encoding", "bo:fileformat", "filetype" },
  },
  extensions = { "nvim-tree", "toggleterm" },
})
