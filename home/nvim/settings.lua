-- [[ Leader ]]

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.netrw_browsex_viewer= "xdg-open"
vim.g.netrw_liststyle = 3

-- [[ Colorsheme ]]

-- vim.cmd [[
--
-- inoremap <silent><expr> <C-Space> compe#complete()
-- inoremap <silent><expr> <CR>      compe#confirm(luaeval("require 'nvim-autopairs'.autopairs_cr()"))
-- inoremap <silent><expr> <C-e>     compe#close('<C-e>')
-- inoremap <silent><expr> <C-f>     compe#scroll({ 'delta': +4 })
-- inoremap <silent><expr> <C-d>     compe#scroll({ 'delta': -4 })
--
-- set completeopt=menu,menuone,noselect
-- ]]

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "netrw", "terminal" },
  callback = function()
    vim.opt_local.number = true
    vim.opt_local.relativenumber = true
  end,
})

vim.cmd([[command! -nargs=0 W wa ]])
vim.cmd([[command! -nargs=0 Wb lua RunWb()]])

function RunWb()
  vim.cmd('wa')
  _G.runScript()
  vim.cmd('mode')
end

function _G.runScript()
    local script_path = './bsync.sh'
    local cmd = 'sh ' .. script_path
    os.execute(cmd)
    -- if not success or exit_code ~= 0 then
    --     vim.api.nvim_err_writeln('Error running script: ' .. script_path)
    -- else
    --     vim.api.nvim_out_write('Script executed successfully\n')
    -- end
end

-- [[ Setting options ]]
-- See `:help vim.o`

-- Set highlight on search
vim.o.hlsearch = false
vim.o.incsearch = true

-- Make line numbers default
vim.wo.number = true
vim.wo.relativenumber = true
-- vim.o.colorcolumn = "80"

-- Enable mouse mode
vim.o.mouse = 'a'

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.o.clipboard = 'unnamedplus'

-- Enable break indent
vim.o.breakindent = true
vim.o.smartindent = true
vim.o.tabstop = 2
vim.o.expandtab = true
vim.o.softtabstop = 2
vim.o.shiftwidth = 2


-- Save undo history
vim.o.undofile = true
vim.o.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.o.swapfile = false
vim.o.backup = false

-- Case insensitive searching UNLESS /C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'
vim.o.scrolloff = 8

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeout = true
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

-- [[ My Functions ]]
vim.api.nvim_create_user_command('ObRun', function()
  local old_buf = vim.api.nvim_get_current_buf()

  if vim.api.nvim_buf_get_option(old_buf, 'buftype') == 'terminal' then
    local ok, job_id = pcall(vim.api.nvim_buf_get_var, old_buf, 'terminal_job_id')
    if ok and type(job_id) == 'number' then
      vim.api.nvim_chan_send(job_id, "\3")
      vim.wait(100)
    end
  end

  vim.cmd('terminal ob run')
  vim.api.nvim_buf_delete(old_buf, { force = true })
end, {})

-- [[ Basic Keymaps ]]

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
-- My new ones
vim.keymap.set('n', '<Leader>r', ':ObRun<CR>', { noremap = true, silent = true })

vim.keymap.set("n", "<C-z>", "<Nop>", { noremap = true, silent = true })

vim.keymap.set('t', '<C-n>', '<C-\\><C-n>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>bs', ':belowrigh split | ')
vim.keymap.set('n', '<leader>bv', ':vsplit | ')

vim.keymap.set("v", "ga", ":EasyAlign ")
vim.keymap.set("n", "ga", ":EasyAlign ")

vim.keymap.set("i", "<C-f>", "<esc>la")

vim.keymap.set("n", "<leader>e", vim.cmd.Ex)
vim.keymap.set("n", "<leader>o", function()
  require("oil").open_float()
end, { desc = "Open Oil", silent = true })

-- moves highlighted lines
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- brings the next line up but maintains the start position
vim.keymap.set("n", "J", "mzJ`z")

-- page up / down but still centres
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- search terms cursor stay in the middle
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- sends deleted item to void so paste continues with original yank
vim.keymap.set("x", "<leader>p", [["_dP]])

-- This is going to get me cancelled
vim.keymap.set("i", "<C-c>", "<Esc>")

-- just stops this doing anything
vim.keymap.set("n", "Q", "<nop>")

--tmux
-- vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")

-- open stack ghci in another window
-- vim.keymap.set("n", "<leader>ng", "<cmd>silent !tmux split-window -l 20 'nix develop --command cabal repl'<CR>")
-- vim.keymap.set("n", "<leader>nn", "<cmd>silent !tmux split-window -l 20 'nix develop'<CR>")
-- vim.keymap.set("n", "<leader>nt", "<cmd>silent !tmux split-window -l 20<CR>")

-- reformat Haskell and elm
vim.keymap.set("n", "<leader>fh", "<cmd>silent %!stylish-haskell<CR>")
-- vim.keymap.set("n", "<leader>ff", "<cmd>silent %!fourmolu -i . --indentation=2 --function-arrows=leading --indent-wheres=true --import-export-style=leading &%<CR>")
-- vim.keymap.set("n", "<leader>fe", "<cmd>silent %!elm-format --yes %<CR>")

-- quick fix navigation
vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

-- lets you change all instances of the word you are on
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

-- opens undotree
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)
vim.g.undotree_CustomUndotreeCmd  = 'rightbelow vertical 30 new'
vim.g.undotree_CustomDiffpanelCmd = 'rightbelow 10 new'

--
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

vim.api.nvim_create_user_command("NA", function(opts)
  local l1, l2 = opts.line1, opts.line2
  local text   = opts.args or ""
  local cmd = string.format("%d,%dnormal A%s", l1, l2, text)
  vim.cmd(cmd)
end, {
  range = true,
  nargs = "*",
})

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- Resize splits with Ctrl+Shift+H/J/K/L
vim.keymap.set("n", "<C-Left>", ":vertical resize -5<CR>", { silent = true })
vim.keymap.set("n", "<C-Right>", ":vertical resize +5<CR>", { silent = true })
vim.keymap.set("n", "<C-Up>", ":resize +5<CR>", { silent = true })
vim.keymap.set("n", "<C-Down>", ":resize -5<CR>", { silent = true })
