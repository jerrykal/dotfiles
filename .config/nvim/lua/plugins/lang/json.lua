return {
  {
    "nvim-lspconfig",
    dependencies = {
      { "b0o/SchemaStore.nvim", version = false },
    },
    opts = {
      servers = {
        jsonls = {
          -- lazy-load schemastore when needed
          before_init = function(_, new_config)
            new_config.settings.json.schemas = new_config.settings.json.schemas or {}
            vim.list_extend(new_config.settings.json.schemas, require("schemastore").json.schemas())
          end,
          settings = {
            json = {
              validate = { enable = true },
            },
          },
        },
      },
    },
  },
}
