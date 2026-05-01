local ok, chat = pcall(require, "CopilotChat")
if not ok then
  return
end

chat.setup({
  window = {
    layout = "vertical",
    width = 0.4,
  },

  mappings = {
    reset = {
      normal = "<leader>cx",
      insert = "<C-x>",
    },
    submit_prompt = {
      normal = "<CR>",
      insert = "<C-s>",
    },
  },
})

vim.keymap.set("n", "<leader>cc", "<cmd>CopilotChatToggle<CR>", {
  desc = "Copilot Chat: toggle",
  silent = true,
})

vim.keymap.set("n", "<leader>cq", function()
  local input = vim.fn.input("Copilot Chat: ")
  if input ~= "" then
    vim.cmd("CopilotChat " .. vim.fn.escape(input, " "))
  end
end, {
  desc = "Copilot Chat: ask",
  silent = true,
})

vim.keymap.set("v", "<leader>cc", ":CopilotChatVisual<CR>", {
  desc = "Copilot Chat: selected code",
  silent = true,
})

vim.keymap.set("v", "<leader>ce", ":CopilotChatExplain<CR>", {
  desc = "Copilot Chat: explain selection",
  silent = true,
})

vim.keymap.set("v", "<leader>cr", ":CopilotChatReview<CR>", {
  desc = "Copilot Chat: review selection",
  silent = true,
})

vim.keymap.set("v", "<leader>cf", ":CopilotChatFix<CR>", {
  desc = "Copilot Chat: fix selection",
  silent = true,
})
