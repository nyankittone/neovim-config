-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = vim.api.nvim_create_augroup('YankHighlight', { clear = true }),
  pattern = '*',
})

-- making sure our cursor is set to the correct one on exit
vim.api.nvim_create_autocmd("ExitPre", {
  group = vim.api.nvim_create_augroup("Exit", {clear = true}),
  command = "set guicursor=a:hor90",
  desc = "Set cursor back to beam when leaving Neovim.",
})

