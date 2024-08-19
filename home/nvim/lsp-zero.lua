require('lsp-zero').setup{}

local lsp = require("lsp-zero")
lsp.preset("recommended")
local lspconfig = require('lspconfig')
-- Use system installed lsps
lsp.configure('lua_ls', {
  force_setup = true,
})

lsp.configure('pylsp', {
  force_setup = true,
})

lsp.configure('hls', {
  force_setup = true,
  root_dir = function(fname)
    -- First, search for a .cabal file in the current or parent directories
    local cabal_root = lspconfig.util.root_pattern('*.cabal')(fname)

    -- If a .cabal file is found, use that as the root
    if cabal_root then
      return cabal_root
    end

    -- Otherwise, fall back to searching for a cabal.project or .git directory
    return lspconfig.util.root_pattern('cabal.project', '.git')(fname)
  end,
  settings = {
    haskell = {
      formattingProvider = 'ormolu'
    }
  }
})

lsp.configure('nil_ls', {
  force_setup = true
})

lsp.configure('clangd', {
  force_setup = true
})

lsp.configure('asm_lsp', {
  force_setup = true
})

local cmp = require('cmp')
local cmp_select = {behavior = cmp.SelectBehavior.Select}
cmp.setup({
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  mappings = lsp.defaults.cmp_mappings({
    ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
    ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
    ['<C-z>'] = cmp.mapping.confirm({ select = true }),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<Tab>'] = nil,
    ['<S-Tab>'] = nil,
  })
})

-- :help lsp-zero-guide:fix-extend-lspconfig

-- lsp.setup_nvim_cmp({
--   mapping = cmp_mappings
-- })

lsp.set_preferences({
    suggest_lsp_servers = false,
    sign_icons = {
        error = 'E',
        warn = 'W',
        hint = 'H',
        info = 'I'
    }
})

-- look at the primagens setup
lsp.on_attach(function(client, bufnr)
  local opts = {buffer = bufnr, remap = false}

  vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
  vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
  vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
  vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float(nil, { focusable = true }) end, opts)
  vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
  vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
  vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
  vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
  vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
  vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
end)

lsp.extend_lspconfig()
lsp.setup()
vim.g.lsp_zero_extend_lspconfig = 0

vim.diagnostic.config({
    virtual_text = true
})

