-- require('lsp-zero').setup{}

local lsp = require("lsp-zero")
lsp.preset("recommended")

-- Neovim 0.11+ deprecates the lspconfig "framework" API.
-- lsp-zero v3 still relies on it; silence the warning until lsp-zero migrates.
vim.g.lspconfig_deprecation_warning = 0

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

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*.fk",
  callback = function()
    vim.bo.filetype = "haskell"
  end,
})

lsp.configure('hls', {
  force_setup = true,
  filetypes   = { "haskell", "lhaskell", "fk" },
  -- Avoid requiring lspconfig.util directly (deprecated path in Neovim 0.11+).
  root_dir = function(fname)
    local ok, util = pcall(require, 'lspconfig.util')
    if not ok then
      return nil
    end
    return util.root_pattern('*.cabal', 'hie.yaml', '.git')(fname)
  end,
  settings = {
    haskell = {
      formattingProvider = "ormolu",
      plugin = {
        ["ghcide-completions"] = {
          config = {
            autoExtendOn = true,
            snippetsOn   = true
          }
        },
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

-- lsp.configure('asm_lsp', {
--   force_setup = true,
--   settings = {
--     assembler = "nasm",
--     arch = "x86_64",
--   }
-- })

-- Basic JDTLS config
lsp.configure('jdtls', {
  cmd = (function()
    local home = os.getenv("HOME")
    local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
    local workspace_dir = home .. "/.local/share/eclipse/" .. project_name

    return { 'jdtls', '-data', workspace_dir }
  end)(),

  -- Optional: what counts as a project root
  root_dir = function(fname)
    local ok, util = pcall(require, 'lspconfig.util')
    if not ok then
      return nil
    end
    return util.root_pattern(
      'pom.xml',
      'build.gradle',
      '.git'
    )(fname)
  end,
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
  on_attach = function(_, _)
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
local ht = require('haskell-tools')
lsp.on_attach(function(_, bufnr)
  local opts = { buffer = bufnr, remap = false }
  local opts2 = { buffer = 0, silent = true, noremap = true }

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
  -- Window navigation shortcuts (match common tmux/vim-tmux-navigator muscle memory)
  -- These mirror the standard <C-w>{h,j,k,l} window moves.
  vim.keymap.set({ "n", "t" }, "<C-h>", "<C-w>h", opts)
  vim.keymap.set({ "n", "t" }, "<C-j>", "<C-w>j", opts)
  vim.keymap.set({ "n", "t" }, "<C-k>", "<C-w>k", opts)
  vim.keymap.set({ "n", "t" }, "<C-l>", "<C-w>l", opts)

  -- Keep signature help on a different key to avoid clobbering <C-k> window navigation.
  vim.keymap.set("i", "<C-s>", function() vim.lsp.buf.signature_help() end, opts)
  vim.keymap.set("n", "<leader>dc", function() require'dap'.continue() end, opts)
  vim.keymap.set("n", "<leader>db", function() require'dap'.toggle_breakpoint() end, opts)
  vim.keymap.set("n", "<leader>ds", function() require'dap'.step_over() end, opts)
  vim.keymap.set("n", "<leader>di", function() require'dap'.step_into() end, opts)
  vim.keymap.set("n", "<leader>do", function() require'dap'.step_out() end, opts)
  vim.keymap.set("n", "<leader>uo", function() require'dapui'.open() end, opts)
  vim.keymap.set("n", "<leader>uc", function() require'dapui'.close() end, opts)
  -- vim.keymap.set('n','<leader>hs', ht.hoogle.hoogle_signature, {buffer=0})
  vim.keymap.set('n', '<leader>hs', ht.hoogle.hoogle_signature, opts2)
end)

lsp.setup()

vim.diagnostic.config({
    virtual_text = true,
})

