-- Defer Avante setup until after startup to avoid Neovim's "Press ENTER" prompt
-- caused by any messages emitted while loading/building avante_lib or validating env.
if vim.g.__avante_config_loaded then
  return
end
vim.g.__avante_config_loaded = true

local prompts_dir = vim.fn.expand("~/.local/share/nvim/ai-workspace/prompts")

local function setup_avante()
  pcall(function()
    require("avante_lib").load()
  end)

  local ok, avante = pcall(require, "avante")
  if not ok then
    vim.notify("avante.nvim failed to load", vim.log.levels.WARN)
    return
  end

  local opts = {
    mode = "agentic",

    provider = "openai",
    providers = {
      openai = {
        model = os.getenv("OPENAI_MODEL") or "gpt-4o",
      },
    },

    -- Upstream option name (top-level)
    instructions_file = "avante.md",

    behaviour = {
      auto_suggestions = false,
      auto_apply_diff_after_generation = false,
      auto_approve_tool_permissions = false,
      confirmation_ui_style = "popup",
    },

    rules = {
      global_dir = prompts_dir,
    },

    mappings = {
      submit = {
        insert = "<C-z>",
      },
    },

    ui = {
      chat = {
        border = "rounded",
      },
    },
  }

  -- Provider config migration (Jun 2025): keep provider settings under `providers`.
  -- Avoid setting top-level `openai`/`ollama`/`vendors` keys, as they are deprecated
  -- and will emit warnings on startup.

  avante.setup(opts)
end

vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    -- Schedule to ensure the UI is ready.
    vim.schedule(setup_avante)
  end,
})

local function read_file(path)
  local ok, lines = pcall(vim.fn.readfile, path)
  if not ok then
    vim.notify("Failed to read preset: " .. path, vim.log.levels.ERROR)
    return nil
  end
  return table.concat(lines, "\n")
end

local function pick_avante_preset_and_insert()
  local files = vim.fn.globpath(prompts_dir, "*", false, true)
  if #files == 0 then
    vim.notify("No presets found in " .. prompts_dir, vim.log.levels.WARN)
    return
  end

  table.sort(files)
  local items = vim.tbl_map(function(p)
    return { label = vim.fn.fnamemodify(p, ":t"), path = p }
  end, files)

  vim.ui.select(items, {
    prompt = "Avante preset:",
    format_item = function(item) return item.label end,
  }, function(choice)
    if not choice then return end

    local text = read_file(choice.path)
    if not text or text == "" then return end

    -- Insert at cursor
    local row, col = table.unpack(vim.api.nvim_win_get_cursor(0))
    local insert_lines = vim.split(text .. "\n", "\n", { plain = true })
    vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, insert_lines)
  end)
end

vim.keymap.set({ "n", "i" }, "<leader>ap", pick_avante_preset_and_insert, {
  desc = "Avante: insert prompt preset",
})
