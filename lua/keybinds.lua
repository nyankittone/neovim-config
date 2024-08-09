-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

-- keybinds for exiting terminal mode
vim.keymap.set('t', '<C-b><C-b>', '<C-\\><C-n>', {desc = 'Exit terminal mode'})
vim.keymap.set('t', '<C-b><ESC>', '', {desc = [[oops I don't want to exit terminal mode actually]]})
vim.keymap.set('t', '<C-b><C-n>', '<C-b>', {desc = 'Send Ctrl-B in terminal mode'})

-- keybinds for navigating windows and shit
-- TODO: Consider changing this to use Alt instead of Ctrl
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', {desc = 'Move to left window'})
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', {desc = 'Move to lower window', remap = true})
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', {desc = 'Move to upper window', remap = true})
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', {desc = 'Move to right window'})

-- these keybinds don't work for some reason, but they're supposed to move windows around...
vim.keymap.set('n', '<M-H>', '<C-w><C-H>', {desc = 'Move window to left'})
vim.keymap.set('n', '<M-J>', '<C-w><C-J>', {desc = 'Move window to lower'})
vim.keymap.set('n', '<M-K>', '<C-w><C-K>', {desc = 'Move window to upper'})
vim.keymap.set('n', '<M-L>', '<C-w><C-L>', {desc = 'Move window to right'})

-- Top 10 funny keybinds
vim.keymap.set('n', '<leader>tv', [[<C-w>v<C-w><C-l>:term
i]])
vim.keymap.set('n', '<leader>ts', [[<C-w>s<C-w><C-j>:term
i]])
vim.keymap.set('n', '<leader>tr', [[:term
i]])
vim.keymap.set('n', '<leader>tt', [[:tabe
:term
i]])

-- Why can't it find "telescope.builtin" from here??? Strange... I might be able to work around
-- this...
-- print(require("telescope.builtin"))

