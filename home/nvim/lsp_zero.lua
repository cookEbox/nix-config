-- require('lsp-zero').setup{}

local lsp = require("lsp-zero")
lsp.preset("recommended")

lsp.extend_lspconfig()

-- Use system installed lsps
lsp.configure('lua_ls', {
  force_setup = true,
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
    },
  },
})

lsp.configure('ts_ls', {
  force_setup = true,
})

lsp.configure('pylsp', {
  force_setup = true,
})

lsp.configure('hls', {
  force_setup = true,
  root_dir = require('lspconfig.util').root_pattern('*.cabal', 'hie.yaml', '.git'),
    settings = {
      haskell = {
      formattingProvider = "ormolu",
      plugin = {
        ghcide = { globalOn = true },
        tactics = { globalOn = true },
        retrie = { globalOn = true },
        hlint = { globalOn = true },
      },
    },
  },
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

lsp.configure('metals', {
  force_setup = true,
  settings = {
    useBloop = true,
    showImplicitArguments = true,
    superMethodLensesEnabled = true,
    showInferredType = true,
    excludedPackages = {},
  },
  init_options = {
    statusBarProvider = "on",
    inpurBoxProvider = "on",
  },
  on_attach = function(client, bufnr)
    require("metals").setup_dap() -- Ensure DAP setup for Scala debugging
    require("dapui").setup() -- Optional, if you use dap-ui
  end,
})

lsp.set_sign_icons({
  error = '✘',
  warn  = '▲',
  hint  = '⚑',
  info  = '»'
})

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
        virtual_text = false,
        underline = false
    }
)

lsp.on_attach(function(client, bufnr)
  local opts = {buffer = bufnr, remap = false}

  vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
  vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
  vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
  vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float(nil, { focusable = true }) end, opts)
  vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
  vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
  vim.keymap.set("n", '<leader>dd', '<cmd>Telescope diagnostics<CR>', { noremap = true, silent = true })
  vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
  vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
  vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
  vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
  vim.keymap.set("n", "<leader>dc", function() require'dap'.continue() end, opts)
  vim.keymap.set("n", "<leader>db", function() require'dap'.toggle_breakpoint() end, opts)
  vim.keymap.set("n", "<leader>ds", function() require'dap'.step_over() end, opts)
  vim.keymap.set("n", "<leader>di", function() require'dap'.step_into() end, opts)
  vim.keymap.set("n", "<leader>do", function() require'dap'.step_out() end, opts)
  vim.keymap.set("n", "<leader>uo", function() require'dapui'.open() end, opts)
  vim.keymap.set("n", "<leader>uc", function() require'dapui'.close() end, opts)
end)

lsp.setup()

vim.diagnostic.config({
    virtual_text = true,
})

