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

-- keybinds for terminal mode
vim.keymap.set('t', '<ESC><ESC>', '<C-\\><C-n>', {desc = 'Exit terminal mode'})

-- keybinds for navigating windows and shit
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', {desc = 'Move to left window'})
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', {desc = 'Move to lower window'})
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', {desc = 'Move to upper window'})
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', {desc = 'Move to right window'})

-- these keybinds don't work for some reason, but they're supposed to move windows around...
vim.keymap.set('n', '<M-H>', '<C-w><C-H>', {desc = 'Move window to left'})
vim.keymap.set('n', '<M-J>', '<C-w><C-J>', {desc = 'Move window to lower'})
vim.keymap.set('n', '<M-K>', '<C-w><C-K>', {desc = 'Move window to upper'})
vim.keymap.set('n', '<M-L>', '<C-w><C-L>', {desc = 'Move window to right'})

