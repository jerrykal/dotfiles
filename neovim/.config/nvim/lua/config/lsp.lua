require("mason").setup()

local mason_lsp = require("mason-lspconfig")
mason_lsp.setup({
  automatic_installation = true,
})

-- Setup lsp servers
local servers = {
  clangd = {},
  pyright = {},
  sumneko_lua = {
    settings = {
      Lua = {
        diagnostics = { globals = { "vim" } },
      },
      format = {
        enable = false,
      },
    },
  },
}

local on_attach = function(client, bufnr)
  if client.server_capabilities.documentSymbolProvider then
    require("nvim-navic").attach(client, bufnr)
    vim.wo.winbar = "  %{%v:lua.require'nvim-navic'.get_location()%}"
  end
  require("config.lsp_mappings").setup(client, bufnr)
end
local capabilities = require("cmp_nvim_lsp").default_capabilities()

for server, opts in pairs(servers) do
  opts.on_attach = on_attach
  opts.capabilities = capabilities
  require("lspconfig")[server].setup(opts)
end

-- Install some editing tools
local tools = {
  "black",
  "isort",
  "stylua",
}
for _, tool in ipairs(tools) do
  local package = require("mason-registry").get_package(tool)
  if not package:is_installed() then
    package:install()
  end
end

-- Setup null-ls
local null_ls = require("null-ls")
null_ls.setup({
  sources = {
    null_ls.builtins.formatting.black,
    null_ls.builtins.formatting.isort,
    null_ls.builtins.formatting.stylua,
  },
})

-- Setup navic
require("nvim-navic").setup({
  icons = {
    File = " ",
    Module = " ",
    Namespace = " ",
    Package = " ",
    Class = " ",
    Method = " ",
    Property = " ",
    Field = " ",
    Constructor = " ",
    Enum = " ",
    Interface = " ",
    Function = " ",
    Variable = " ",
    Constant = " ",
    String = " ",
    Number = " ",
    Boolean = " ",
    Array = " ",
    Object = " ",
    Key = " ",
    Null = " ",
    EnumMember = " ",
    Struct = " ",
    Event = " ",
    Operator = " ",
    TypeParameter = " ",
  },
  highlight = true,
})

-- Setup fidget.nvim
require("fidget").setup()

-- Setup diagnostics
vim.diagnostic.config({
  virtual_text = false,
})
vim.fn.sign_define("DiagnosticSignError", { text = "", numhl = "DiagnosticError" })
vim.fn.sign_define("DiagnosticSignWarn", { text = "", numhl = "DiagnosticWarn" })
vim.fn.sign_define("DiagnosticSignInfo", { text = "", numhl = "DiagnosticInfo" })
vim.fn.sign_define("DiagnosticSignHint", { text = "", numhl = "DiagnosticHint" })
