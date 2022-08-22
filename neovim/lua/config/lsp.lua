local sign_define = vim.fn.sign_define
sign_define('DiagnosticSignError', {text = '', numhl = 'DiagnosticError'})
sign_define('DiagnosticSignWarn',  {text = '', numhl = 'DiagnosticWarn'})
sign_define('DiagnosticSignInfo',  {text = '', numhl = 'DiagnosticInfo'})
sign_define('DiagnosticSignHint',  {text = '', numhl = 'DiagnosticHint'})

local lsp = vim.lsp
lsp.handlers['textDocument/publishDiagnostics'] = lsp.with(lsp.diagnostic.on_publish_diagnostics, {
  virtual_text = false,
  signs = true,
  update_in_insert = false,
  underline = true,
})

local function on_attach(client, bufnr)
  require('mappings').lspconfig(client, bufnr)
end

local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

local enhance_server_opts = {
  ['clangd'] = function(opts)
    opts.cmd = {
      'clangd',
      '--header-insertion=never'
    }
  end
}

local lsp_installer = require('nvim-lsp-installer')
lsp_installer.on_server_ready(function(server)
  local opts = {
    on_attach = on_attach,
    capabilities = capabilities
  }
  if enhance_server_opts[server.name] then
    enhance_server_opts[server.name](opts)
  end
  server:setup(opts)
end)

