return {
  {
    "stevearc/conform.nvim",
    dependencies = {
      {
        "mason.nvim",
        opts = {
          -- Formatters listed here will be automatically installed
          ensure_installed = {
            "ruff",
            "stylua",
            "shfmt",
          },
        },
      },
    },
    event = { "BufWritePre" },
    cmd = "ConformInfo",
    opts = {
      default_format_opts = {
        timeout_ms = 3000,
        async = false,
        quiet = false,
        lsp_format = "fallback",
      },
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "ruff_fix", "ruff_organize_imports", "ruff_format" },
        sh = { "shfmt" },
      },
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
