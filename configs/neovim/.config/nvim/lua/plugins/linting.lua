return {
  {
    "mfussenegger/nvim-lint",
    dependencies = { "mason-org/mason.nvim" },
    event = "LazyFile",
    opts = {
      linters_by_ft = {
        markdown = { "markdownlint", "vale" },
      },
    },
    config = function(_, opts)
      local lint = require("lint")
      lint.linters_by_ft = opts.linters_by_ft

      local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        group = lint_augroup,
        callback = function()
          if vim.bo.modifiable then
            lint.try_lint()
          end
        end,
      })
    end,
  },

  -- Linters listed here will be automatically installed
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "markdownlint",
        "vale",
      },
    },
  },
}
