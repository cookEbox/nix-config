local lsp_config = require("lspconfig")
local lsp_completion = require("compe")

--Enable completion
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

local general_on_attach = function(client, bufnr)
  if client.resolved_capabilities.completion then
    lsp_completion.on_attach(client, bufnr)
  end
end

-- Setup basic lsp servers
for _, server in pairs({"html", "cssls"}) do
  lsp_config[server].setup {
    -- Add capabilities
    capabilities = capabilities,
    on_attach = general_on_attach,
  }
end

require('neodev').setup()
require'lspconfig'.lua_ls.setup {
  on_attach = general_on_attach,
  capabilities = capabilities,
  cmd = { "/home/nick/.local/share/nvim/mason/bin/lua-language-server" },
  filetypes = { "lua" },
  log_level = 2,
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT'
      },
      semantic = {
        enable = false,
      },
      diagnostics = {
        globals = { "vim "},
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
      },
      telemetry = { enable = false },
      completion = {
        callSnippet = "Replace",
      },
    },
  },
}

require('lspconfig').rnix.setup{}
require('lspconfig').hls.setup{}
require('lspconfig').tsserver.setup{}
-- require('lspconfig').html.setup{}
-- require('lspconfig').cssls.setup{} 


-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)

-- LSP settings.
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
  -- local ht = require('haskell-tools')
  local opts = {buffer = bufnr, remap = false }
  vim.keymap.set('n', '<leader>ca', vim.lsp.codelens.run, opts)
  -- vim.keymap.set("n", '<leader>hs', ht.hoogle.hoogle_signature, opts)
  -- vim.keymap.set("n", '<leader>ea', ht.lsp.buf_eval_all, opts)
  -- NOTE: Remember that lua is a real programming language, and as such it is possible
  -- to define small helper and utility functions so you don't have to repeat yourself
  -- many times.
  --
  -- In this case, we create a function that lets us more easily define mappings specific
  -- for LSP related items. It sets the mode, buffer and description for us each time.
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

  nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
  nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  nmap('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
  nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
  nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
  nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

  -- See `:help K` for why this keymap
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

  -- Lesser used LSP functionality
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  nmap('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })
end
