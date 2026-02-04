-- Neovim LSP configuration (without lsp-zero)
--
-- This avoids the deprecated lspconfig "framework" API that lsp-zero relies on
-- in Neovim 0.11+.

local ok_lspconfig, lspconfig = pcall(require, "lspconfig")
if not ok_lspconfig then
  return
end

-- Diagnostics UI
vim.diagnostic.config({
  virtual_text = true,
  underline = false,
})

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics,
  {
    virtual_text = false,
    underline = false,
  }
)

local function on_attach(_, bufnr)
  local opts = { buffer = bufnr, remap = false }
  local opts2 = { buffer = 0, silent = true, noremap = true }

  vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
  vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
  vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
  vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float(nil, { focusable = true }) end, opts)
  vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
  vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
  vim.keymap.set("n", "<leader>dd", "<cmd>Telescope diagnostics<CR>", { noremap = true, silent = true })
  vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
  vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
  vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)

  -- Window navigation shortcuts (match common tmux/vim-tmux-navigator muscle memory)
  vim.keymap.set({ "n", "t" }, "<C-h>", "<C-w>h", opts)
  vim.keymap.set({ "n", "t" }, "<C-j>", "<C-w>j", opts)
  vim.keymap.set({ "n", "t" }, "<C-k>", "<C-w>k", opts)
  vim.keymap.set({ "n", "t" }, "<C-l>", "<C-w>l", opts)

  -- Keep signature help on a different key to avoid clobbering <C-k> window navigation.
  vim.keymap.set("i", "<C-s>", function() vim.lsp.buf.signature_help() end, opts)

  vim.keymap.set("n", "<leader>dc", function() require("dap").continue() end, opts)
  vim.keymap.set("n", "<leader>db", function() require("dap").toggle_breakpoint() end, opts)
  vim.keymap.set("n", "<leader>ds", function() require("dap").step_over() end, opts)
  vim.keymap.set("n", "<leader>di", function() require("dap").step_into() end, opts)
  vim.keymap.set("n", "<leader>do", function() require("dap").step_out() end, opts)
  vim.keymap.set("n", "<leader>uo", function() require("dapui").open() end, opts)
  vim.keymap.set("n", "<leader>uc", function() require("dapui").close() end, opts)

  local ok_ht, ht = pcall(require, "haskell-tools")
  if ok_ht then
    vim.keymap.set("n", "<leader>hs", ht.hoogle.hoogle_signature, opts2)
  end
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
local ok_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
if ok_cmp then
  capabilities = cmp_lsp.default_capabilities(capabilities)
end

-- Filetype override for *.fk
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*.fk",
  callback = function()
    vim.bo.filetype = "haskell"
  end,
})

-- Server configs
lspconfig.lua_ls.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
    },
  },
})

-- TypeScript: keep your existing server name (ts_ls) if that's what you have installed.
if lspconfig.ts_ls then
  lspconfig.ts_ls.setup({
    on_attach = on_attach,
    capabilities = capabilities,
  })
elseif lspconfig.tsserver then
  lspconfig.tsserver.setup({
    on_attach = on_attach,
    capabilities = capabilities,
  })
end

lspconfig.pylsp.setup({
  on_attach = on_attach,
  capabilities = capabilities,
})

lspconfig.hls.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "haskell", "lhaskell", "fk" },
  root_dir = function(fname)
    local ok, util = pcall(require, "lspconfig.util")
    if not ok then
      return nil
    end
    return util.root_pattern("*.cabal", "hie.yaml", ".git")(fname)
  end,
  settings = {
    haskell = {
      formattingProvider = "ormolu",
      plugin = {
        ["ghcide-completions"] = {
          config = {
            autoExtendOn = true,
            snippetsOn = true,
          },
        },
        tactics = { globalOn = true },
        retrie = { globalOn = true },
        hlint = { globalOn = true },
      },
    },
  },
})

lspconfig.nil_ls.setup({
  on_attach = on_attach,
  capabilities = capabilities,
})

lspconfig.clangd.setup({
  on_attach = on_attach,
  capabilities = capabilities,
})

-- JDTLS (Java)
lspconfig.jdtls.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  cmd = (function()
    local home = os.getenv("HOME")
    local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
    local workspace_dir = home .. "/.local/share/eclipse/" .. project_name
    return { "jdtls", "-data", workspace_dir }
  end)(),
  root_dir = function(fname)
    local ok, util = pcall(require, "lspconfig.util")
    if not ok then
      return nil
    end
    return util.root_pattern("pom.xml", "build.gradle", ".git")(fname)
  end,
})

-- Metals (Scala)
local ok_metals, metals = pcall(require, "metals")
if ok_metals then
  lspconfig.metals.setup({
    on_attach = function(client, bufnr)
      on_attach(client, bufnr)
      metals.setup_dap()
      pcall(function() require("dapui").setup() end)
    end,
    capabilities = capabilities,
    settings = {
      useBloop = true,
      showImplicitArguments = true,
      superMethodLensesEnabled = true,
      showInferredType = true,
      excludedPackages = {},
    },
    init_options = {
      statusBarProvider = "on",
      inputBoxProvider = "on",
    },
  })
end

