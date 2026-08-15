-- Neovim LSP configuration using the Neovim 0.11+ API (`vim.lsp.config`).
--
-- This intentionally avoids `require('lspconfig')`, which is deprecated.
--
-- Scala/Metals is the exception to the generic native-LSP setup below:
-- nvim-metals still uses Neovim's built-in LSP client, but it owns the Metals
-- attach lifecycle so build import, Metals commands, DAP, and extensions work.

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

-- Some servers/plugins may return duplicate locations for definition.
-- De-duplicate quickfix items by (filename, lnum, col) before presenting them.
local function dedupe_qf_items(items)
  local seen = {}
  local out = {}

  for _, item in ipairs(items) do
    local filename = item.filename or ""
    local lnum = item.lnum or 0
    local col = item.col or 0
    local key = string.format("%s:%d:%d", filename, lnum, col)

    if not seen[key] then
      seen[key] = true
      table.insert(out, item)
    end
  end

  return out
end

local function on_list_dedup(opts)
  opts.items = dedupe_qf_items(opts.items or {})

  if #opts.items == 0 then
    vim.notify("No location found", vim.log.levels.INFO)
    return
  end

  -- Use quickfix for multi-location results.
  vim.fn.setqflist({}, " ", opts)
  if #opts.items == 1 then
    vim.cmd("cfirst")
  else
    vim.cmd("copen")
  end
end

local function safe_require(module_name)
  local ok, module = pcall(require, module_name)
  if ok then
    return module
  end

  return nil
end

local function on_attach(_, bufnr)
  -- Avoid running mappings multiple times if the same buffer gets multiple
  -- LSP clients attached. This flag is deliberately about keymaps only.
  if vim.b[bufnr].__lsp_keymaps_done then
    return
  end
  vim.b[bufnr].__lsp_keymaps_done = true

  local opts = { buffer = bufnr, remap = false }
  local opts2 = { buffer = bufnr, silent = true, noremap = true }

  vim.keymap.set("n", "gd", function() vim.lsp.buf.definition({ on_list = on_list_dedup }) end, opts)
  vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
  vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
  vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float(nil, { focusable = true }) end, opts)
  vim.keymap.set("n", "[d", function() vim.diagnostic.goto_prev() end, opts)
  vim.keymap.set("n", "]d", function() vim.diagnostic.goto_next() end, opts)
  vim.keymap.set("n", "<leader>dd", "<cmd>Telescope diagnostics<CR>", { buffer = bufnr, noremap = true, silent = true })
  vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
  vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
  vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)

  -- Window/pane navigation is handled by vim-tmux-navigator for seamless nvim <-> tmux.
  -- Don't override its default <C-h/j/k/l> mappings here.

  -- Keep signature help on a different key to avoid clobbering <C-k> window navigation.
  vim.keymap.set("i", "<C-s>", function() vim.lsp.buf.signature_help() end, opts)

  local dap = safe_require("dap")
  if dap then
    vim.keymap.set("n", "<leader>dc", function() dap.continue() end, opts)
    vim.keymap.set("n", "<leader>db", function() dap.toggle_breakpoint() end, opts)
    vim.keymap.set("n", "<leader>ds", function() dap.step_over() end, opts)
    vim.keymap.set("n", "<leader>di", function() dap.step_into() end, opts)
    vim.keymap.set("n", "<leader>do", function() dap.step_out() end, opts)
  end

  local dapui = safe_require("dapui")
  if dapui then
    vim.keymap.set("n", "<leader>uo", function() dapui.open() end, opts)
    vim.keymap.set("n", "<leader>uc", function() dapui.close() end, opts)
  end

  local ht = safe_require("haskell-tools")
  if ht then
    vim.keymap.set("n", "<leader>hs", ht.hoogle.hoogle_signature, opts2)
  end
end

-- Ensure keymaps are applied even when a server is started by another plugin
-- (e.g. haskell-tools). Ignore Copilot here because it can attach before the
-- real language server and otherwise mark the buffer as already configured.
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.name ~= "copilot" then
      on_attach(client, args.buf)
    end
  end,
})

local capabilities = lsp.protocol.make_client_capabilities()
local cmp_lsp = safe_require("cmp_nvim_lsp")
if cmp_lsp then
  capabilities = cmp_lsp.default_capabilities(capabilities)
end

-- haskell-tools.nvim owns the HLS lifecycle. Do not also register or start a
-- separate generic "hls" client below.
vim.g.haskell_tools = {
  tools = {
    hover = {
      -- Put focus in the enhanced hover so <CR> can follow its "Go to" action.
      auto_focus = true,
    },
  },
  hls = {
    cmd = { "haskell-language-server-wrapper", "--lsp" },
    capabilities = capabilities,

    on_attach = function(client, bufnr)
      on_attach(client, bufnr)

      -- Use haskell-tools' enhanced hover rather than the generic LSP hover.
      vim.keymap.set("n", "K", function()
        vim.cmd.Haskell({ "hover" })
      end, {
        buffer = bufnr,
        silent = true,
        noremap = true,
        desc = "Haskell hover actions",
      })

      local goto_preview = safe_require("goto-preview")
      if goto_preview then
        vim.keymap.set("n", "gK", goto_preview.goto_preview_type_definition, {
          buffer = bufnr,
          silent = true,
          noremap = true,
          desc = "Preview Haskell type definition",
        })
      end
    end,
    default_settings = {
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
  },
}

-- Helper: only enable a server if its executable is available.
local function can_exec(cmd)
  if type(cmd) == "string" then
    return vim.fn.executable(cmd) == 1
  end

  if type(cmd) == "table" and type(cmd[1]) == "string" then
    return vim.fn.executable(cmd[1]) == 1
  end

  return false
end

-- Helper: safely register a server config if available.
local function maybe_setup(server_name, cfg)
  if type(server_name) ~= "string" or type(cfg) ~= "table" then
    return
  end

  if not can_exec(cfg.cmd) then
    -- Don’t spam errors when the binary isn’t installed.
    return
  end

  lsp.config[server_name] = cfg
end

-- Filetype override for *.fk
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*.fk",
  callback = function()
    vim.bo.filetype = "haskell"
  end,
})

-- Neovim 0.11+: `vim.lsp.config` defines server configurations, but in this
-- file we start most generic servers explicitly from FileType autocmds. Metals
-- is started separately via nvim-metals further below.
local function start_lsp_for_buffer(server_name)
  local cfg = lsp.config[server_name]
  if type(cfg) ~= "table" then
    return
  end

  if cfg.cmd and not can_exec(cfg.cmd) then
    return
  end

  -- Avoid starting multiple clients for the same buffer.
  -- Some plugins may start the same underlying server command with a different
  -- client name, which leads to duplicated diagnostics.
  local bufnr = vim.api.nvim_get_current_buf()
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
    if client.name == server_name then
      return
    end

    if type(cfg.cmd) == "table" and type(client.config) == "table" and type(client.config.cmd) == "table" then
      if cfg.cmd[1] ~= nil and client.config.cmd[1] == cfg.cmd[1] then
        return
      end
    end
  end

  -- Ensure the client has a name, used for de-duplication and health output.
  local start_cfg = vim.tbl_deep_extend("force", { name = server_name }, cfg)
  vim.lsp.start(start_cfg)
end

-- Server configs

-- Lua LSP. Nix provides the binary as `lua-language-server`.
maybe_setup("lua_ls", {
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
})

-- Nix LSP: the server binary is `nil`, but the config name is `nil_ls`.
maybe_setup("nil_ls", {
  cmd = { "nil" },
  capabilities = capabilities,
  on_attach = on_attach,
})

-- TypeScript. Only starts if typescript-language-server is in PATH.
maybe_setup("ts_ls", {
  cmd = { "typescript-language-server", "--stdio" },
  capabilities = capabilities,
  on_attach = on_attach,
})

-- Python. Only starts if pylsp is in PATH.
maybe_setup("basedpyright", {
  cmd = { "basedpyright-langserver", "--stdio" },
  capabilities = capabilities,
  on_attach = on_attach,
})

-- C/C++/Objective-C. Only starts if clangd is in PATH.
maybe_setup("clangd", {
  cmd = { "clangd" },
  capabilities = capabilities,
  on_attach = on_attach,
})

-- JDTLS (Java). Do not auto-start for Java because Metals also uses Java files
-- in Scala projects. Start jdtls manually if/when you want standalone Java LSP.
maybe_setup("jdtls", {
  capabilities = capabilities,
  on_attach = on_attach,
  cmd = (function()
    local home = os.getenv("HOME")
    local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
    local workspace_dir = home .. "/.local/share/eclipse/" .. project_name
    return { "jdtls", "-data", workspace_dir }
  end)(),
})

-- Generic LSP startup autocmds.
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

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
  callback = function()
    start_lsp_for_buffer("ts_ls")
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    start_lsp_for_buffer("basedpyright")
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c", "cpp", "objc", "objcpp" },
  callback = function()
    start_lsp_for_buffer("clangd")
  end,
})

-- Metals (Scala)
--
-- Do not also configure Metals via `vim.lsp.config("metals", ...)` or
-- `vim.lsp.enable("metals")`. nvim-metals owns the attach lifecycle here.
local metals = safe_require("metals")
if metals then
  local metals_config = metals.bare_config()

  metals_config.cmd = { vim.env.NVIM_METALS_CMD }

  metals_config.cmd_env = vim.tbl_deep_extend("force", metals_config.cmd_env or {}, {
    JAVA_HOME = vim.env.NVIM_METALS_JAVA_HOME,
    METALS_JAVA_HOME = vim.env.NVIM_METALS_JAVA_HOME,
    PATH = vim.env.NVIM_METALS_JAVA_HOME .. "/bin:" .. vim.env.PATH,
  })
  metals_config.capabilities = capabilities

  metals_config.on_attach = function(client, bufnr)
    on_attach(client, bufnr)

    pcall(function()
      metals.setup_dap()
    end)

    local dapui = safe_require("dapui")
    if dapui then
      pcall(function()
        dapui.setup()
      end)
    end
  end

  metals_config.settings = vim.tbl_deep_extend("force", metals_config.settings or {}, {
    showImplicitArguments = true,
    superMethodLensesEnabled = true,
    showInferredType = true,
    excludedPackages = {},
  })

  metals_config.init_options = vim.tbl_deep_extend("force", metals_config.init_options or {}, {
    statusBarProvider = "on",
    inputBoxProvider = "on",
  })

  local metals_group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })

  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "scala", "sbt", "java" },
    callback = function()
      metals.initialize_or_attach(metals_config)
    end,
    group = metals_group,
  })
end
