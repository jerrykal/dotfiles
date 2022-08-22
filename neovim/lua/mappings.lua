local map = vim.keymap.set

local M = {}

-- General mappings
M.misc = function()
  -- Allow moving the cursor through wrapped lines with j, k
  map('', 'j', 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', {expr = true})
  map('', 'k', 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', {expr = true})

  -- Select all
  map('n', '<C-a>', 'ggVG')

  -- use ESC to turn off search highlighting
  map('n', '<Esc>', ':noh<CR>')

  -- Press ESC twice to enter normal mode in terminal
  map('t', '<ESC><ESC>', '<C-\\><C-n>')

  -- System clipboard copy/paste
  map('n', '<leader>y', '"+y')
  map('n', '<leader>Y', '"+Y')
  map('n', '<leader>p', '"+p')
  map('n', '<leader>P', '"+P')
  map('v', '<leader>y', '"+y')
  map('v', '<leader>p', '"+p')
  map('v', '<leader>P', '"+P')

  -- Window movement
  map('n', '<C-h>', '<C-w>h')
  map('n', '<C-j>', '<C-w>j')
  map('n', '<C-k>', '<C-w>k')
  map('n', '<C-l>', '<C-w>l')

  -- Buffer mappings
  map('n', '<leader>w', '<cmd>w<CR>', {silent = true})
  map('n', '<leader>n', '<cmd>enew<CR>', {silent = true})
end

-- Plugin mappings below

-- BBye
M.bbye = function()
  map('n', '<leader>x', '<cmd>Bdelete<CR>', {silent = true})
  map('n', '<leader>X', '<cmd>Bdelete!<CR>', {silent = true})
end

-- Bufferline
M.bufferline = function()
  map('n', '<leader>]', '<cmd>BufferLineCycleNext<CR>', {silent = true})
  map('n', '<leader>[', '<cmd>BufferLineCyclePrev<CR>', {silent = true})
  map('n', '<leader>1', '<cmd>BufferLineGoToBuffer 1<CR>', {silent = true})
  map('n', '<leader>2', '<cmd>BufferLineGoToBuffer 2<CR>', {silent = true})
  map('n', '<leader>3', '<cmd>BufferLineGoToBuffer 3<CR>', {silent = true})
  map('n', '<leader>4', '<cmd>BufferLineGoToBuffer 4<CR>', {silent = true})
  map('n', '<leader>5', '<cmd>BufferLineGoToBuffer 5<CR>', {silent = true})
  map('n', '<leader>6', '<cmd>BufferLineGoToBuffer 6<CR>', {silent = true})
  map('n', '<leader>7', '<cmd>BufferLineGoToBuffer 7<CR>', {silent = true})
  map('n', '<leader>8', '<cmd>BufferLineGoToBuffer 8<CR>', {silent = true})
  map('n', '<leader>9', '<cmd>BufferLineGoToBuffer 9<CR>', {silent = true})
  map('n', '<leader>0', '<cmd>BufferLineGoToBuffer 10<CR>', {silent = true})
end

-- Telescope
M.telescope = function()
  map('n', '<leader>f<TAB>', '<cmd>Telescope builtin<CR>')
  map('n', '<leader>fb', '<cmd>Telescope buffers<CR>')
  map('n', '<leader>ff', '<cmd>Telescope find_files<CR>')
  map('n', '<leader>fa', '<cmd>Telescope find_files no_ignore=true hidden=true<CR>')
  map('n', '<leader>fg', '<cmd>Telescope live_grep<CR>')
  map('n', '<leader>fh', '<cmd>Telescope help_tags<CR>')
  map('n', '<leader>fr', '<cmd>Telescope oldfiles<CR>')
  map('n', '<leader>fm', '<cmd>Telescope marks<CR>')
  map('n', '<C-p>', '<cmd>Telescope find_files<CR>')
end

-- Undotree
M.undotree = function()
  map('n', '<F5>', '<cmd>UndotreeToggle<CR>')
end

-- NvimTree
M.nvimtree = function()
  map('n', '<C-n>', '<cmd>NvimTreeToggle<CR>')
end

-- LSP
M.lspconfig = function(client, bufnr)
  local function buf_set_keymap(...)
    vim.api.nvim_buf_set_keymap(bufnr, ...)
  end
  local opts = {noremap = true, silent = true}

  buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', 'gk', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('n', '<leader>Wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<leader>Wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<leader>Wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  buf_set_keymap('n', '<leader>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', '<leader>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
  buf_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', '<leader>q',  '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)

  if client.resolved_capabilities.document_formatting then
    buf_set_keymap('n', '<leader>F',  '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
    buf_set_keymap('v', '<leader>F',  ':lua vim.lsp.buf.range_formatting()<CR>', opts)
  end
end

return M
