-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Enable true color support (required for nvim-tree and many color schemes)
vim.opt.termguicolors = true
-- tab width
--
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- cursor
vim.opt.cursorline = true
vim.opt.cursorcolumn = true
vim.opt.number = true         -- line number
vim.opt.relativenumber = true -- relative line number
vim.opt.numberwidth = 10


-- Sync clipboard between OS and Neovim
-- This makes yank to clipboard which allow copy across nvim and OS
vim.opt.clipboard = 'unnamedplus'

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

vim.opt.wrap = false -- Wrap line when text reach the end

vim.api.nvim_set_keymap('i', '<C-h>', '<Left>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<C-j>', '<Down>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<C-k>', '<Up>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<C-l>', '<Right>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'ff', '^', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'fj', '$', { noremap = true, silent = true })

vim.keymap.set('n', '<CR>', 'o<Esc>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })
vim.keymap.set('i', '<C-b>', '<Backspace>', { desc = 'Move focus to the upper window' })

-- TIP: Disable arrow keys in normal mode
vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- lsp
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'Go to definition' })
vim.keymap.set('n', 'K', '<cmd>Lspsaga hover_doc<CR>', { desc = 'Hover documentation', silent = true })
vim.keymap.set('n', 'gp', '<cmd>Lspsaga peek_definition<CR>', { desc = 'Peek definition', silent = true })
vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { desc = 'Rename symbol' })
vim.keymap.set({ 'n', 'v' }, '<leader>ca', '<cmd>Lspsaga code_action<CR>', { desc = 'Code action', silent = true })

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

local opts = { noremap = true, silent = true }
vim.keymap.set("n", "<leader>bn", ":BufferNext<CR>", opts)               -- 下一個 buffer
vim.keymap.set("n", "<leader>bp", ":BufferPrevious<CR>", opts)           -- 上一個 buffer
vim.keymap.set("n", "<leader>bc", ":BufferClose<CR>", opts)              -- 關閉 buffer
vim.keymap.set("n", "<leader>ba", ":BufferCloseAllButCurrent<CR>", opts) -- 關閉 buffer
vim.keymap.set("n", "<leader>bb", ":BufferPick<CR>", opts)               -- 選擇 buffer

-- 快速水平/垂直分割
vim.keymap.set("n", "<leader>sh", ":split<CR>", opts)
vim.keymap.set("n", "<leader>sv", ":vsplit<CR>", opts)

vim.keymap.set('n', '<leader>fp', ':Telescope projects<CR>', { noremap = true, silent = true })

vim.keymap.set("n", "<leader>do", "<cmd>DiffviewOpen<CR>", { desc = "Open Diffview" })
vim.keymap.set("n", "<leader>dc", "<cmd>DiffviewClose<CR>", { desc = "Close Diffview" })
vim.keymap.set("n", "<leader>dh", "<cmd>DiffviewFileHistory<CR>", { desc = "File History" })

vim.keymap.set('t', '<C-h>', [[<C-\><C-n><C-w>h]])
vim.keymap.set('t', '<C-j>', [[<C-\><C-n><C-w>j]])
vim.keymap.set('t', '<C-k>', [[<C-\><C-n><C-w>k]])
vim.keymap.set('t', '<C-l>', [[<C-\><C-n><C-w>l]])

vim.keymap.set({ 'n' }, '<leader>tf', ':ToggleTerm direction=float<CR>')
vim.keymap.set({ 'n' }, '<leader>th', ':ToggleTerm direction=vertical<CR>')
vim.keymap.set({ 'n' }, '<leader>lg', ':ToggleTerm direction=vertical<CR> cmd=lg')
