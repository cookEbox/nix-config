pcall(function() require("avante_lib").load() end)

require("avante").setup({
  behaviour = {
    auto_suggestions = false,
    auto_apply_diff = false,
  },
  rules = {
    global_dir = vim.fn.expand("~/.local/share/nvim/ai-workspace/prompts")
  },
  mappings = {
    submit = {
      insert = "<C-z>",
    },
  },
  provider = "openai",
  openai = {
    model   = os.getenv("OPENAI_MODEL") or "gpt-4o",
  },
  project = {
    instructions_file = "avante.md",
  },

  ui = {
    chat = {
      border = "rounded",
    },
  },
})

local prompts_dir = vim.fn.expand("~/.local/share/nvim/ai-workspace/prompts")

local function pick_avante_preset_and_insert()
  local files = vim.fn.globpath(prompts_dir, "*.md", false, true)
  if #files == 0 then
    vim.notify("No preset files found in " .. prompts_dir, vim.log.levels.WARN)
    return
  end

  table.sort(files)
  local items = vim.tbl_map(function(p)
    return { name = vim.fn.fnamemodify(p, ":t:r"), path = p }
  end, files)

  vim.ui.select(items, {
    prompt = "Avante preset:",
    format_item = function(item) return item.name end,
  }, function(choice)
    if not choice then return end

    local ok, lines = pcall(vim.fn.readfile, choice.path)
    if not ok then
      vim.notify("Failed to read " .. choice.path, vim.log.levels.ERROR)
      return
    end

    local text = table.concat(lines, "\n")
    if text == "" then return end

    -- Insert at cursor in the current buffer (Avante input included)
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local insert_lines = vim.split(text .. "\n", "\n", { plain = true })
    vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, insert_lines)
  end)
end

vim.keymap.set({ "n", "i" }, "<leader>ap", pick_avante_preset_and_insert, {
  desc = "Avante: insert prompt preset",
})

