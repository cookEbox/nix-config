-- Neovim LSP configuration using the Neovim 0.11+ API (`vim.lsp.config`).
--
-- This intentionally avoids `require('lspconfig')`, which is deprecated.

local lsp = vim.lsp
if type(lsp) ~= "table" or type(lsp.config) ~= "table" then
  -- Older Neovim; nothing to do.
  return
end

-- Diagnostics UI
vim.diagnostic.config({
  virtual_text = true,
  underline = false,
})

-- Neovim 0.11+ no longer uses the legacy publishDiagnostics handler.
-- Configure diagnostics via vim.diagnostic.config() only.

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

local capabilities = lsp.protocol.make_client_capabilities()
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

-- Neovim 0.11+: `vim.lsp.config` defines server configs, but you still need to
-- start/enable them for relevant buffers.
local function start_lsp_for_buffer(server_name)
  local cfg = lsp.config[server_name]
  if type(cfg) ~= "table" then
    return
  end

  -- Avoid starting multiple clients for the same buffer.
  local bufnr = vim.api.nvim_get_current_buf()
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
    if client.name == server_name then
      return
    end
  end

  -- Ensure the client has a name (used for de-duplication and :LspInfo).
  local start_cfg = vim.tbl_deep_extend("force", { name = server_name }, cfg)
  vim.lsp.start(start_cfg)
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "nix",
  callback = function()
    start_lsp_for_buffer("nil_ls")
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "lua",
  callback = function()
    start_lsp_for_buffer("lua_ls")
  end,
})

-- Server configs
--
-- Note: `vim.lsp.config` defines server configurations. Starting the servers is
-- handled by Neovim when a matching filetype is opened.

-- Explicit cmd is required for non-builtin server definitions.
-- Nix provides the binary as `lua-language-server`.
lsp.config.lua_ls = {
  cmd = { "lua-language-server" },
  capabilities = capabilities,
  on_attach = on_attach,
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
    },
  },
}

-- TypeScript: prefer `ts_ls` if present, otherwise `tsserver`.
-- (The actual server binary must be available in PATH.)
lsp.config.ts_ls = {
  capabilities = capabilities,
  on_attach = on_attach,
}

lsp.config.tsserver = {
  capabilities = capabilities,
  on_attach = on_attach,
}

lsp.config.pylsp = {
  capabilities = capabilities,
  on_attach = on_attach,
}

lsp.config.hls = {
  capabilities = capabilities,
  on_attach = on_attach,
  filetypes = { "haskell", "lhaskell", "fk" },
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
}

-- Nix LSP: the server binary is `nil`, but the config name is `nil_ls`.
-- Neovim's built-in LSP uses the config name to decide what to start.
-- Nix provides the server binary as `nil`.
lsp.config.nil_ls = {
  cmd = { "nil" },
  capabilities = capabilities,
  on_attach = on_attach,
}

lsp.config.clangd = {
  capabilities = capabilities,
  on_attach = on_attach,
}

-- JDTLS (Java)
lsp.config.jdtls = {
  capabilities = capabilities,
  on_attach = on_attach,
  cmd = (function()
    local home = os.getenv("HOME")
    local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
    local workspace_dir = home .. "/.local/share/eclipse/" .. project_name
    return { "jdtls", "-data", workspace_dir }
  end)(),
}

-- Metals (Scala)
local ok_metals, metals = pcall(require, "metals")
if ok_metals then
  lsp.config.metals = {
    capabilities = capabilities,
    on_attach = function(client, bufnr)
      on_attach(client, bufnr)
      metals.setup_dap()
      pcall(function() require("dapui").setup() end)
    end,
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
  }
end

