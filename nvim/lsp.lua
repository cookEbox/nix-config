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
    on_attach = general_on_attach
  }
end

require('lspconfig').rnix.setup{}
require('lspconfig').hls.setup{}
require('lspconfig').tsserver.setup{}
require('lspconfig').html.setup{}
require('lspconfig').cssls.setup{} 

require('compe').setup {
  enabled = true;
  autocomplete = true;
  debug = false;
  min_length = 1;
  preselect = 'enable';
  throttle_time = 88;
  source_timeout = 200;
  incomplete_delay = 400;
  max_abbr_width = 100;
  max_kind_width = 100;
  max_menu_width = 100;
  documentation = false;

  source = {
    path = true;
    buffer = true;
    nvim_lsp = true;
    nvim_lua = true;
    tags = true;
    treesitter = true;
  };
}


local t = function(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end
_G.tab_complete = function()
  if vim.fn.pumvisible() == 1 then
    return t "<C-n>"
  else
    return t "<S-Tab>"
  end
end

vim.api.nvim_set_keymap("i", "<Tab>", "v:lua.tab_complete()", {expr = true})
vim.api.nvim_set_keymap("s", "<Tab>", "v:lua.tab_complete()", {expr = true})
