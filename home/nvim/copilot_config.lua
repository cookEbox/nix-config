local ok, copilot = pcall(require, "copilot")
if not ok then
  return
end

copilot.setup({
  panel = { enabled = false },
  suggestion = {
    enabled = true,
    auto_trigger = false,
    hide_during_completion = true,
    debounce = 75,
    keymap = {
      accept = "<C-l>",
      next = "<M-n>",
      prev = "<M-p>",
      dismiss = "<C-]>",
    },
  },
  nes = { enabled = false },
  should_attach = function(_, bufname)
    local name = (bufname or ""):lower()
    local base = vim.fs.basename(name)

    if base:match("^%.env") then
      return false
    end

    if name:match("secret") or name:match("secrets") then
      return false
    end

    if name:match("%.pem$") or name:match("%.key$") or name:match("%.p12$") then
      return false
    end

    return true
  end,
})

