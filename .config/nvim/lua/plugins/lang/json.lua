return {
  {
    "nvim-lspconfig",
    dependencies = { "b0o/schemastore.nvim" },
    opts = {
      servers = {
        jsonls = function()
          return {
            settings = {
              json = {
                schemas = require("schemastore").json.schemas(),
                validate = { enable = true },
              },
            },
          }
        end,
      },
    },
  },
}
