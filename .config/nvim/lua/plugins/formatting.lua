return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = "ConformInfo",
    opts = {
      default_format_opts = {
        timeout_ms = 3000,
        async = false,
        quiet = false,
        lsp_format = "fallback",
      },
      formatters_by_ft = {},
      format_on_save = {
        lsp_format = "fallback",
        timeout_ms = 500,
      },
    },
    -- stylua: ignore
    keys = {
      { "<leader>cf", function() require("conform").format() end, mode = { "n", "x" }, desc = "Format selected range", },
    },
  },
}
